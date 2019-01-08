module KeyDial

	class KeyDialler

		@obj_with_keys
		@lookup
		@default = nil

		def initialize(obj_with_keys, *lookup)
			if obj_with_keys.respond_to?(:dig)
				@obj_with_keys = obj_with_keys
			else
				raise ArgumentError.new('HashDialler must be initialized on a Hash, Array or Struct, or an object that responds to :dig.')
			end
			@lookup = []
			if lookup.length > 0
				dial!(*lookup)
			end
		end

		# Adds a key to the list of nested keys to try, one level deeper.
		#
		# @param keys The key to add. Multiple arguments would add multiple keys.
		#
		def dial!(*keys)
			#unless key.is_a(Symbol) || key.is_a(String)
			@lookup += keys
			return self
		end

		# Digs into the object to the list of keys specified by dialling. Returns nil or default if specified.
		#
		# @param default What to return if no key is found.
		#
		def call(default = nil)
			begin
				value = @obj_with_keys.dig(*@lookup)
			rescue
				value = default
			end
			return value
		end

		# Return the original keyed object.
		def hangup
			return @obj_with_keys
		end

		# Remove keys from the dialling list.
		#
		# @param keys If specified, these keys would be removed from wherever they appear in the dialling list. Otherwise, the last added key is removed.
		#
		def undial!(*keys)
			if keys.length > 0
				@lookup -= keys
			elsif @lookup.length > 0
				@lookup.pop
			end
			return self
		end

		# The preferred way to build up your dialling list. Access KeyDialler as if it were a keyed object, e.g. keydialler[a][b][c]. This does not actually return any value, rather it dials those keys (awaiting a call).
		#
		def [](key)
			return dial!(key)
		end
		def +(key)
			return dial!(key)
		end
		def -(key)
			return undial!(key)
		end

	end

end
