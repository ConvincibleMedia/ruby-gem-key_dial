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

		def dial!(*keys)
			#unless key.is_a(Symbol) || key.is_a(String)
			@lookup += keys
			return self
		end

		def call(default = nil)
			begin
				value = @hash.dig(*@lookup)
			rescue
				value = default
			end
			return value
		end

		def hangup
			return @hash
		end

		def undial!(*keys)
			if keys.length > 0
				@lookup -= keys
			elsif @lookup.length > 0
				@lookup.pop
			end
			return self
		end

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
