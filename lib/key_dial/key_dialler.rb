module KeyDial

	class KeyDialler

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
		# @param keys The key to add. Multiple arguments would add multiple keys.
		#
		def dial!(*keys_array)
			#unless key.is_a(Symbol) || key.is_a(String)
			keys_array = use_keys(keys_array)
			@lookup += keys_array
			return self
		end

		# Remove keys from the dialling list.
		#
		# @param keys If specified, these keys would be removed from wherever they appear in the dialling list. Otherwise, the last added key is removed.
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

		# Digs into the object to the list of keys specified by dialling. Returns nil or default if specified.
		#
		# @param default What to return if no key is found.
		#
		def call(default = @default)
			begin
				value = @obj_with_keys.dig(*@lookup)
			rescue
				value = default
			end
			return value
		end

		# Return the array of keys dialled so far.
		def keys
			return @lookup
		end

		# Return the original keyed object.
		def object
			return @obj_with_keys
		end
		alias hangup object

		# Set/change the keyed object.
		def object=(obj_with_keys)
			obj_with_keys = DEFAULT_OBJECT if obj_with_keys.nil?
			if obj_with_keys.respond_to?(:dig)
				@obj_with_keys = obj_with_keys
			else
				raise ArgumentError.new('HashDialler must be used on a Hash, Array or Struct, or object that responds to the .dig method.')
			end
		end

		# The preferred way to build up your dialling list. Access KeyDialler as if it were a keyed object, e.g. keydialler[a][b][c]. This does not actually return any value, rather it dials those keys (awaiting a call).
		#
		def [](key)
			return dial!(key)
		end

		# Set any deep key. If keys along the way don't exist, empty Hashes or Arrays will be created. Warning: this method will try to coerce your main object to match the structure implied by your keys.
		def []=(key_obj, value_obj)
			# Hashes can be accessed at [Object] of any kind
			# Structs can be accessed at [String] and [Symbol], and [Integer] for the nth member (or [Float] which rounds down)
			# Arrays can be accessed at [Integer] or [Float] which rounds down

			# Dial the key to be set - @lookup can never be empty
			dial!(key_obj)

			index = 0
			@lookup.inject(@obj_with_keys) { |deep_obj, this_key|

				# this = object to be accessed
				# key = key to access on this
				# access = what kind of key is key

				next_key = @lookup[index + 1]
				last_key = @lookup[index - 1] if index > 0
				key = {
					this: {
						type: nil,
						value: this_key
					},
					next: {
						type: nil,
						value: next_key
					}
				}

				[:this, :next].each { |which|
					if key[which][:value].is_a?(Integer) || key[which][:value].is_a?(Float)
						key[which][:type] = :number
						key[which][:max] = key[which][:value].magnitude.floor + 1
					else
						key[which][:type] = :object
						key[which][:type] = :string if key[which][:value].is_a?(String)
						key[which][:type] = :symbol if key[which][:value].is_a?(Symbol)
					end
				}

				reconstruct = false

				# Ensure this object is a supported type - always true for index == 0
				if !deep_obj.class.included_modules.include?(KeyDial)
					# Not a supported type! e.g. a string
					if key[:this][:type] == :number
						puts 'woop'
						deep_obj = Array.new(key[:this][:max] - 1).unshift(deep_obj)
					else
						deep_obj = {0 => deep_obj}
					end
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
						elsif key[:this][:type] == :number
							if key[:this][:max] > deep_obj.size
								# You asked for it!
								# Create new numeric members up to key requested
								new_members = deep_obj.members.concat(
									(deep_obj.size..(key[:this][:max] - 1)).to_a.map { |num| num.to_s.to_sym }
								)
								deep_obj = Struct.new(*new_members).new(*deep_obj.values)
								reconstruct = true
							end
						end
					end

					# "You asked for it!"(TM)
					# If accessing an array with a key that doesn't exist, we'll add elements to the array or change the array to a hash. This is dangerous but it's your fault.
					if deep_obj.is_a?(Array)
						if key[:this][:type] == :number
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
					}[last_key] = deep_obj
				end

				# Does this object already have this key?
				if !deep_obj.call(key[:this][:value])
					# If not, create empty array/hash dependant on upcoming key
					if key[:next][:type] == :number
						deep_obj[key[:this][:value]] = Array.new(key[:next][:max])
					else
						deep_obj[key[:this][:value]] = {key[:next][:value] => nil}
					end
				end

				# Quit if this is the penultimate or last iteration
				next deep_obj if index >= @lookup.size - 1

				# Increment index manually
				index += 1

				# Before here, we must make sure we can access key on deep_obj
				deep_obj[key[:this][:value]]

			# Final access (and set) of last key in the @lookup - by this point should be guaranteed to work!
			}[@lookup[-1]] = value_obj


			if false

				# WHAT TO DO WHEN SETTING A KEY YOU JUST CAN'T SET



			end

		end

		# You can add and subtract keys from a KeyDialler object
		def +(key)
			return dial!(key)
		end
		def -(key)
			return undial!(key)
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
