module KeyDial

	module Coercion

		module Hashes

			# Convert {a: 1, b: 2, c: 3} to <Struct :a=1, :b=2, :c=3>
			def to_struct(type_class = nil)
				return Coercion::Structs.create(self, type_class)
			end

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

				def from(obj)
					return obj if obj.is_a?(Hash)
					return obj.to_hash if obj.is_a?(Array)
					return obj.to_h if obj.is_a?(Struct)
					return {0 => obj}
				end

			end

		end

		module Arrays

			# Convert ['a', 'b', 'c'] to {0: 'a', 1: 'b', 2: 'c'}
			def to_hash
				self.each_with_index.map { |k, i|
					if k.is_a?(Array)
						[i, nil] if k.size == 0
						[i, k] if k.size == 1
						k if k.size == 2
						[k[0], k[1..-1]] if k.size > 2
					else
						[i, k]
					end
				}.to_h
			end

			# Convert ['a', 'b', 'c'] to <Struct :'0'='a', :'1'='b', :'2'='c'>
			def to_struct(type_class = nil)
				return Coercion::Structs.create(self, type_class)
			end

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

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

			def self.included(base)
			   	base.extend ClassMethods
			end

			module ClassMethods

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

			def self.create(from_obj, type_class = nil)
				#binding.pry
				if from_obj.is_a?(Hash) || from_obj.is_a?(Array) || from_obj.is_a?(Struct)
				 	return EMPTY.dup if from_obj.size == 0
					from = from_obj
				else
					from = [from_obj]
				end

				if type_class.is_a?(Class) && type_class < Struct
					if from.is_a?(type_class)
						return from
					else
						values = []
						if from.is_a?(Array)
							values = from.values.first(type_class.members.size)
						else
							type_class.members.each { |key|
								if from.key?(key)
									values << from[key]
								else
									values << nil
								end
							}
						end
						return type_class.new(*values)
					end
				else
				new_values = from.values
				new_keys = from.keys.each_with_index.map { |k, i|
					if k.respond_to?(:to_sym) && k != ''
						k.to_sym
					elsif k.respond_to?(:to_s) && !k.nil?
						k.to_s.to_sym
					else
						new_values.delete_at(i)
						nil
					end
				}.reject(&:nil?)
					if new_keys.size > 0
						return Struct.new(*new_keys).new(*new_values)
					else
						return EMPTY.dup
					end
				end

			rescue
				return EMPTY.dup
			end

		end

	end

end
