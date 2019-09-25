module KeyDial

	module Coercion

		module Hashes

			# Convert a Hash to a Struct. {a: 1, b: 2, c: 3} will become <Struct :a=1, :b=2, :c=3>
			#
			def to_struct(type_class = nil)
				return Coercion::Structs.create(self, type_class)
			end

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				# Allows you to do Hash.from(obj) to create a Hash from any object intelligently.
				#
				def from(obj)
					return obj if obj.is_a?(Hash)
					return obj.to_hash if obj.is_a?(Array)
					return obj.to_h if obj.is_a?(Struct)
					return {0 => obj}
				end

			end

		end

		module Arrays

			# Convert an Array to a Hash, providing an alternative to the native to_h() method. to_hash() is more forgiving and avoids errors. ['a', 'b', 'c'] will become {0 => 'a', 1 => 'b', 2 => 'c'}
			#
			def to_hash
				self.each_with_index.map { |k, i|
					if k.is_a?(Array)
						if k.empty?
							[i, nil]
						elsif k.size == 2
							k # k in this case is a keyval pair, e.g. [k, v]
						else
							[i, k]
						end
					else
						[i, k]
					end
				}.to_h
			end

			# Convert an Array to a Struct. ['a', 'b', 'c'] will become <Struct :'0'='a', :'1'='b', :'2'='c'>
			#
			# @param type_class If a sub-class of Struct is provided, this sub-class will be instantiated
			#
			def to_struct(type_class = nil)
				return Coercion::Structs.create(self, type_class)
			end

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				# Allows you to do Array.from(obj) to create an Array from any object intelligently.
				#
				def from(obj)
					return obj if obj.is_a?(Array)
					return obj.to_a if obj.is_a?(Hash)
					return obj.to_h.to_a if obj.is_a?(Struct)
					return [obj]
				end

			end

		end

		module Structs

			EMPTY = Struct.new(:'0').new.freeze

			# Convert a Struct to another Struct.
			#
			# @param type_class If a sub-class of Struct is provided, the Struct will be converted to this sub-class
			#
			def to_struct(type_class = nil)
				if type_class.is_a?(Class) && type_class < Struct
					return Struct.from(self, type_class)
				else
					return self
				end
			end

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				# Allows you to do Struct.from(obj) to instantiate a Struct using keys/values from any object intelligently.
				#
				# @param type_class If a sub-class of Struct is provided, this sub-class will be instantiated
				#
				def from(obj, type_class = nil)
					if !obj.is_a?(Struct) && !obj.is_a?(Hash) && !obj.is_a?(Array) && type_class == nil
						s = EMPTY.dup
						s[0] = obj
						return s
					else
						return Coercion::Structs.create(obj, type_class)
					end
				end

			end

			# Struct creation function not really meant to be used directly. Prefer Struct.from(obj).
			#
			# @param from_obj Keys/values from this object will be used to fill out the new Struct.
			# @param type_class If a sub-class of Struct is provided, this sub-class will be instantiated
			#
			def self.create(from_obj, type_class = nil)
				if from_obj.is_a?(Hash) || from_obj.is_a?(Array) || from_obj.is_a?(Struct)
				 	return EMPTY.dup if from_obj.empty? && type_class == nil
					from = from_obj
				else
					from = [from_obj]
				end

				# Has a specific type of Struct been specified?
				if type_class.is_a?(Class) && type_class < Struct
					if from.is_a?(type_class)
						# Has an instantiation of that type of Struct been passed in? If so, just return it
						return from
					else
						values = []
						if from.is_a?(Array)
							# Get as many elements of array as this Struct can handle - discard the rest
							values = from.first(type_class.members.size)
						else 
							# Not an Array, so must be another Struct or Hash
							type_class.members.each { |key|
								if from.key?(key)
									# If the object has this expected key, use it
									values << from[key]
								else
									# Otherwise, fill this key with nil
									values << nil
									# Keys in the from object which don't match expected keys are discarded
								end
							}
						end
						# values now contains a value or nil for each of this class's expected keys
						return type_class.new(*values)
					end
				else
					# Anonymous Struct
					new_values = from.is_a?(Array) ? from : from.values
					# Iterate over the keys of the from object
					# (Array.keys is monkeypatched in)
					new_keys = from.keys.each_with_index.map { |k, i|
						if k.respond_to?(:to_sym) && k != ''
							k.to_sym
						elsif k.respond_to?(:to_s) && !k.nil?
							k.to_s.to_sym
						else
							# If we can't construct a valid Struct key for this key, we discard the corresponding value
							new_values.delete_at(i)
							nil
						end
					}.reject(&:nil?)
					if new_keys.size > 0
						# Create anonymous Struct with the specified keys and values
						return Struct.new(*new_keys).new(*new_values)
					else
						# Return the Empty Struct
						return EMPTY.dup
					end
				end

			rescue
				return EMPTY.dup
			end

		end

	end

end
