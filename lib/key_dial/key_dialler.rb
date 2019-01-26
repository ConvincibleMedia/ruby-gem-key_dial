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
