module KeyDial

	module Coercion

		module Coercer
			def to(type)
				if type.is_a?(Class)
					if type == self.class || self.class < type
						return self
					elsif (type == Hash || type < Hash) && type.respond_to?(:from)
						return type.from(self)
					elsif (type == Array || type < Array) && type.respond_to?(:from)
						return type.from(self)
					elsif (type == Struct || type < Struct) && type.respond_to?(:from)
						return type.from(self)
					else
						raise ArgumentError, "Cannot coerce to " + type.to_s
					end
				else
					raise ArgumentError, "Must specify a class to coerce to."
				end
			end
		end

		module Hashes
			
			# Adds .to() method to instances of this class
			include Coercer

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				# Allows you to do Hash.from(obj) to create a Hash from any object intelligently.
				#
				def from(obj)
					case obj
					when Hash
						return obj
					when Array
						# Hash from Array. Forgiving and avoids errors. ['a', 'b', 'c'] will become {0 => 'a', 1 => 'b', 2 => 'c'}
						obj.each_with_index.map { |k, i|
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
					when Struct
						# Hash from Struct
						return obj.to_h
					else
						{0 => obj}
					end
				end

			end

		end

		module Arrays

			# Adds .to() method to instances of this class
			include Coercer

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				# Allows you to do Array.from(obj) to create an Array from any object intelligently.
				#
				def from(obj)
					case obj
					when Array
						return obj
					when Hash
						# Array from Hash
						return obj.to_a
					when Struct
						# Array from Struct
						return obj.to_h.to_a
					else
						return [obj]
					end
				end

			end

		end

		module Structs

			# Adds .to() method to instances of this class
			include Coercer

			EMPTY = Struct.new(:'0').new.freeze

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				# Allows you to do Struct.from(obj) to instantiate a Struct using keys/values from any object intelligently.
				#
				def from(_obj)
					from_obj = _obj
					if !from_obj.is_a?(Struct) && !from_obj.is_a?(Hash) && !from_obj.is_a?(Array)
						return EMPTY if _obj == EMPTY[0]
						return EMPTY if _obj.nil?
						# For non-keyed objects, we will treat the whole object like it's a value to push into the first property of a struct
						from_obj = [_obj]
					end
					
					struct_class = self
	
					# Are we operating on a defined type of Struct?
					if struct_class < Struct
						if from_obj.is_a?(struct_class)
							# Has an instantiation of that type of Struct been passed in? If so, just return it
							return from_obj
						else
							# Get values
							values = []
							if from_obj.is_a?(Array)
								# Get as many elements of array as this Struct can handle - discard the rest
								values = from_obj.first(struct_class.members.size)
							else 
								# Not an Array, so must be another Struct or Hash
								struct_class.members.each { |key|
									if from_obj.key?(key)
										# If the object has this expected key, use it
										values << from_obj[key]
									else
										# Otherwise, fill this key with nil
										values << nil
										# Keys in the from object which don't match expected keys are discarded
									end
								}
							end
							# values now contains a value or nil for each of this class's expected keys
							return struct_class.new(*values)
						end
					else
						# Anonymous Struct
						new_values = from_obj.is_a?(Array) ? from_obj : from_obj.values
						# Iterate over the keys of the from object
						# (Array.keys is monkeypatched in)
						new_keys = from_obj.keys.each_with_index.map { |k, i|
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
							return EMPTY
						end
					end
					
				rescue
					return EMPTY
				end

			end

		end

	end

end
