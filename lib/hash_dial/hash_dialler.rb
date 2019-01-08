module HashDial

	class HashDialler

		@hash
		@lookup
		@default = nil

		def initialize(hash, *lookup)
			if hash.is_a?(Hash)
				@hash = hash
			else
				@hash = {}
			end
			@lookup = []
			if lookup.length > 0
				dial!(*lookup)
			end
		end

		# Adds a hash key to the list of nested keys to try, one level deeper.
		#
		# @param keys The key to add. Multiple arguments would add multiple keys.
		#
		def dial!(*keys)
			#unless key.is_a(Symbol) || key.is_a(String)
			@lookup += keys
			return self
		end

		# Digs into the hash to the list of keys specified by dialling. Returns nil or default if specified.
		#
		# @param default What to return if no key is found.
		#
		def call(default = nil)
			begin
				value = @hash.dig(*@lookup)
			rescue
				value = default
			end
			return value
		end

		# Return the original hash object.
		def hangup
			return @hash
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

		# The preferred way to build up your dialling list. Access HashDialler as if it were a Hash, e.g. hash[a][b][c]. This does not actually return any value, rather it dials those keys (awaiting a call).
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
