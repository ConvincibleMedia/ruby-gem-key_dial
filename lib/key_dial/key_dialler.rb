module KeyDial

	class KeyDialler

		DEFAULT_OBJECT = {}.freeze

		@obj_with_keys
		@lookup
		@default

		def initialize(obj_with_keys = DEFAULT_OBJECT, *lookup)
			self.object = obj_with_keys
			@lookup = []
			@default = nil
			if lookup.length > 0
				dial!(*lookup)
			end
		end

		attr_accessor :default

		# Adds a key to the list of nested keys to try, one level deeper.
		#
		# @param keys_array The key(s) to add. Multiple arguments would add multiple keys.
		#
		def dial!(*keys_array)
			keys_array = use_keys(keys_array)
			@lookup += keys_array
			return self
		end

		# Remove keys from the dialling list.
		#
		# @param keys_array If specified, these keys would be removed from wherever they appear in the dialling list. Otherwise, the last added key is removed.
		#
		def undial!(*keys_array)
			keys_array = use_keys(keys_array)
			if keys_array.length > 0
				@lookup -= keys_array
			elsif @lookup.length > 0
				@lookup.pop
			end
			return self
		end

		# Digs into the object to the list of keys specified by dialling. Returns nil, or default if specified, if the key can't be found.
		#
		# @param default What to return if no key is found.
		#
		def set?
			begin

				value = @lookup.inject(@obj_with_keys) { |deep_obj, this_key|
					# Has to be an object that can have keys
					return false unless deep_obj.respond_to?(:[])

					if deep_obj.respond_to?(:fetch)
						# Hash, Array and Struct all respond to fetch
						# We've monkeypatched fetch to Struct
						if deep_obj.is_a?(Array)
							# Check array separately as must fetch numeric key
							return false unless Keys.index?(this_key)
						end
						next_obj = deep_obj.fetch(this_key, Keys::MISSING)
					else
						return false
					end

					# No need to go any further
					return false if Keys::MISSING == next_obj

					# Reinject value to next loop
					next_obj
				}

			rescue
				# If fetch throws a wobbly at any point, fail gracefully
				return false
			end
			# No errors - yield the value if desired
			if block_given?
				yield(value)
			end
			# Return true
			return true
		end

		def fetch(default = (default_skipped = true; @default))
			value = nil
			if set? { |exists| value = exists }
				return value
			else
				if block_given?
					warn 'warning: block supersedes default value argument' if !default_skipped
					return yield
				else
					return default
				end
			end
		end

		def call(default = (default_skipped = true; @default))
			value = nil
			if set? { |exists| value = exists }
				# Key exists at key list, and we've captured it to value
				if block_given?
					# If block given, yield value to the block
					return yield(value)
				else
					# Otherwise, just return the value
					return value
				end
			else
				# Key does not exist
				if default.is_a?(Proc)
					# If default provided is a Proc, don't just return this as a value - run it
					return default.call
				else
					# Return the default
					return default
				end
			end
		end

		# Return the array of keys dialled so far.
		def keys
			return @lookup
		end

		# Set the key list directly.
		def keys=(keys_array)
			if keys_array.is_a?(Array)
				@lookup = []
				dial!(*keys_array)
			else
				raise ArgumentError, 'Key list must be set to an array.'
			end
		end

		# Return the original keyed object.
		def object
			return @obj_with_keys
		end
		alias hangup object

		# Set/change the keyed object.
		#
		# @param obj_with_keys The object that should be dialled, e.g. a Hash, Array or Struct.
		#
		def object=(obj_with_keys)
			obj_with_keys = DEFAULT_OBJECT if obj_with_keys.nil?
			if obj_with_keys.respond_to?(:fetch)
				@obj_with_keys = obj_with_keys
			else
				raise ArgumentError, 'KeyDialler must be used on a Hash, Array or Struct, or object that responds to the fetch method.'
			end
		end

		# The preferred way to build up your dialling list. Access KeyDialler as if it were a keyed object, e.g. keydialler[a][b][c]. This does not actually return any value, rather it dials those keys (awaiting a call).
		#
		# @param key The key to dial, determined via [key] syntax
		#
		def [](key)
			return dial!(key)
		end

		# The preferred way to set a value at the end of a set of keys. Will create or coerce intermediate keys if required.
		#
		# @param key_obj The last key to dial, determined via [key] syntax
		# @param value_obj What to set it to.
		#
		def []=(key_obj, value_obj)
			# Dial the key to be set - @lookup can never be empty
			dial!(key_obj)
			# Set the value
			return set!(value_obj)
		end

		# The preferred way to add to an array at the end of a set of keys. Will create or coerce the array if required.
		#
		# @param value_obj The value to add to the array at the dialled location.
		#
		def <<(value_obj)
			array = call(Keys::MISSING)
			# Dial the next array key index - @lookup can never be empty before set!()
			if array.is_a?(Array) || array.is_a?(Hash) || array.is_a?(Struct)
				dial!(array.size)
			elsif array == Keys::MISSING
				dial!(0)
			else
				dial!(1)
			end
			return set!(value_obj)
		end

		# Set any deep key. If keys along the way don't exist, empty Hashes or Arrays will be created. Warning: this method will try to coerce your main object to match the structure implied by your keys.
		#
		# @param key_obj The key to alter, determined via [key_obj] syntax
		# @param value_obj What to set this key to, determined via [key_obj] = value_obj syntax
		#
		def set!(value_obj)
			insist!()
			@lookup[0...-1].inject(@obj_with_keys) { |deep_obj, this_key|
				deep_obj[this_key]
			}[@lookup[-1]] = value_obj
		end

		# Forces the current list of dialled keys to be instantiated on the object.
		#
		# @param type_class The object class that must be instantiated at the end of the key list. Either Hash, Array or Struct (or Struct::Type). Will create a new object if the key does not exist, or coerce existing values if it does.
		#
		def insist!(type_class = (type_class_skipped = true; nil))

			return @obj_with_keys if @lookup.empty?
			# Hashes can be accessed at [Object] of any kind
			# Structs can be accessed at [String] and [Symbol], and [Integer] for the nth member (or [Float] which rounds down)
			# Arrays can be accessed at [Integer] or [Float] which rounds down

			index = 0
			# Will run at least twice, as:
			# Always runs once for @obj_with_keys itself
			# Then at least one more time because @lookup is not empty
			return @lookup.inject(@obj_with_keys) { |deep_obj, this_key|
				last_index = index >= @lookup.size - 1

				# this = object to be accessed
				# key = key to access on this
				# access = what kind of key is key

				key = {
					this: {
						type: nil,
						value: this_key
					},
					next: {
						type: nil,
						value: last_index ? Keys::MISSING : @lookup[index + 1]
					},
					last: {
						type: nil,
						value: index == 0 ? Keys::MISSING : @lookup[index - 1]
					}
				}

				key.each { |pos, _|
					if Keys.index?(key[pos][:value])
						key[pos][:type] = :index
						key[pos][:max] = key[pos][:value].magnitude.floor + (key[pos][:value] <= -1 ? 0 : 1)
					else
						key[pos][:type] = :object
						key[pos][:type] = :string if key[pos][:value].is_a?(String)
						key[pos][:type] = :symbol if key[pos][:value].is_a?(Symbol)
					end
				}

				reconstruct = false

				# Ensure this object is a supported type - always true for index == 0 i.e. @obj_with_keys itself
				if !(deep_obj.respond_to?(:fetch) && deep_obj.respond_to?(:[]))
					# Not a supported type! e.g. a string
					if key[:this][:type] == :index
						# If we'll access an array here, re-embed the unsupported object in an array as [0 => original]
						deep_obj = Array.new(key[:this][:max] - 1).unshift(deep_obj)
					else
						# Otherwise, embed the unsupported object in a hash with the key 0
						deep_obj = {0 => deep_obj}
					end
					# Will never run on @obj_with_keys itself
					reconstruct = true
				else
					# Supported type, but what if this doesn't accept that kind of key? Then...

					# "You asked for it!"(TM)
					# In a Struct, if accessing a member that doesn't exist, we'll replace the struct with a redefined anonymous one containing the members you wanted. This is dangerous but it's your fault.
					if deep_obj.is_a?(Struct)
						if key[:this][:type] == :string || key[:this][:type] == :symbol
							if !deep_obj.members.include?(key[:this][:value].to_sym)
								# You asked for it!
								# Add the member you requested
								new_members = deep_obj.members.push(key[:this][:value].to_sym)
								deep_obj = Struct.new(*new_members).new(*deep_obj.values)
								reconstruct = true
							end
						elsif key[:this][:type] == :index
							if key[:this][:max] > deep_obj.size
								# You asked for it!
								# Create new numeric members up to key requested
								if key[:this][:value] <= -1
									range = 0..((key[:this][:max] - deep_obj.size) - 1)
								else
									range = deep_obj.size..(key[:this][:max] - 1)
								end
								new_keys = (range).to_a.map { |num| num.to_s.to_sym }
								# Shove them in
								if key[:this][:value] <= -1
									# Prepend
									new_members = new_keys.concat(deep_obj.members)
									new_values = Array.new(new_keys.size - deep_obj.values.size, nil).concat(deep_obj.values)
								else
									# Append
									new_members = deep_obj.members.concat(new_keys)
									new_values = deep_obj.values
								end
								deep_obj = Struct.new(*new_members).new(*new_values)
								reconstruct = true
							end
						end
					end

					# "You asked for it!"(TM)
					# If accessing an array with a key that doesn't exist, we'll add elements to the array or change the array to a hash. This is dangerous but it's your fault.
					if deep_obj.is_a?(Array)
						if key[:this][:type] == :index
							if key[:this][:value] <= -1 && key[:this][:max] > deep_obj.size
								# You asked for it!
								# The only time an Array will break is if you try to set a negative key larger than the size of the array. In this case we'll prepend your array with nils.
								deep_obj = Array.new(key[:this][:max] - deep_obj.size, nil).concat(deep_obj)
								reconstruct = true
							end
						else
							# You asked for it!
							# Trying to access non-numeric key on an array, so will convert the array into a hash with integer keys.
							deep_obj = deep_obj.each_with_index.map { |v, index| [index, v] }.to_h
							reconstruct = true
						end
					end

				end

				if reconstruct
					# Go back and reinject this altered value into the array
					@lookup[0...(index-1)].inject(@obj_with_keys) { |deep_obj2, this_key2|
						deep_obj2[this_key2]
					}[key[:last][:value]] = deep_obj
				end

				# Does this object already have this key?
				if !deep_obj.dial[key[:this][:value]].set?
					# If not, create empty array/hash dependant on upcoming key
					if type_class_skipped
						if key[:next][:type] == :index
							if key[:next][:value] <= -1
								# Ensure new array big enough to address a negative key
								deep_obj[key[:this][:value]] = Array.new(key[:next][:max])
							else
								# Otherwise, can just create an empty array
								deep_obj[key[:this][:value]] = []
							end
						else
							# Create an empty hash awaiting keys/values
							deep_obj[key[:this][:value]] = {}
						end
					else
						if type_class == Array
							deep_obj[key[:this][:value]] = []
						elsif type_class == Hash
							deep_obj[key[:this][:value]] = {}
						elsif type_class == Struct
							# Why would you do this?
							deep_obj[key[:this][:value]] = Coercion::Structs::EMPTY.dup
						elsif type_class.is_a?(Class) && type_class < Struct
							deep_obj[key[:this][:value]] = type_class.new
						elsif type_class.respond_to?(:new)
							begin
								deep_obj[key[:this][:value]] = type_class.new
							rescue
								deep_obj[key[:this][:value]] = nil
							end
						else
							deep_obj[key[:this][:value]] = nil
						end
					end
				elsif !type_class_skipped && last_index && !deep_obj[key[:this][:value]].is_a?(type_class)
					#Key already exists, but we must ensure it's of the right type
					if type_class == Array
						deep_obj[key[:this][:value]] = Array.from(deep_obj[key[:this][:value]])
					elsif type_class == Hash
						deep_obj[key[:this][:value]] = Hash.from(deep_obj[key[:this][:value]])
					elsif type_class == Struct
						# Why would you do this?
						deep_obj[key[:this][:value]] = Struct.from(deep_obj[key[:this][:value]])
					elsif type_class.is_a?(Class) && type_class < Struct
						deep_obj[key[:this][:value]] = type_class.from(deep_obj[key[:this][:value]])
					elsif type_class == String && deep_obj[key[:this][:value]].respond_to?(:to_s)
						deep_obj[key[:this][:value]] = deep_obj[key[:this][:value]].to_s
					elsif type_class == Symbol
						if deep_obj[key[:this][:value]].respond_to?(:to_sym)
							deep_obj[key[:this][:value]] = deep_obj[key[:this][:value]].to_s
						elsif deep_obj[key[:this][:value]].respond_to?(:to_s)
							deep_obj[key[:this][:value]] = deep_obj[key[:this][:value]].to_s.to_sym
						else
							warn "Could not coerce value to #{type_class}"
						end
					elsif type_class.respond_to?(:new)
						begin
							deep_obj[key[:this][:value]] = type_class.new
						rescue
							warn "Could not coerce value to #{type_class}"
						end
					else
						warn "Could not coerce value to #{type_class}"
					end
				end

				# Quit if this is the penultimate or last iteration
				#next deep_obj if last_index

				# Increment index manually
				index += 1

				# Before here, we must make sure we can access key on deep_obj
				# Return the value at this key for the next part of inject loop
				deep_obj[key[:this][:value]]

			}

			# Final access (and set) of last key in the @lookup - by this point should be guaranteed to work!
			#if value_obj_skipped
			#	return obj_to_set[@lookup[-1]]
			#else
			#	return obj_to_set[@lookup[-1]] = value_obj
			#end

		end

		# Add a key to the dialling chain. If an array is passed, each item in the array will be added in order.
		def +(key)
			return dial!(*key)
		end

		# Remove keys that have been dialled.
		#
		# @param key If an integer n, the last n keys will be removed. Otherwise, all keys matching this argument will be removed from any point in the dialing chain. If an array is passed, each item in the array will be removed.
		#
		def -(key)
			if key.is_a?(Integer) && key > 0
				return key.times { undial! }
			else
				return undial!(*key)
			end
		end

		# Private class method to reduce KeyDialler objects to their contained key arrays if a KeyDialler object itself is passed as a potential key to dial
		private def use_keys(keys_array)
			keys_array = [keys_array] if !keys_array.is_a?(Array)
			keys_array.flatten
			keys_return = []
			keys_array.each { |key|
				if key.is_a?(KeyDialler)
					# Add returned keys inline (flattened into array)
					keys_return += key.keys
				else
					# Add any other key as a whole object
					keys_return.push(key)
				end
			}
			return keys_return
		end

	end

end
