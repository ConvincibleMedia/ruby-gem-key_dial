module HashDial

	class HashDialler

		@hash
		@lookup
		@@default = nil

		def initialize(hash, *lookup)
			if hash.is_a?(Hash)
				@hash = hash
			else
				@hash = {}
			end
			@lookup = []
		end

		def dial!(key)
			#unless key.is_a(Symbol) || key.is_a(String)
			@lookup.push(key)
			return self
		end

		def call
			begin
				value = @hash.dig(*@lookup)
			rescue
				value = @@default
			end
			return value
		end

		def undial!(*keys)
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

		class << self
			attr_accessor :default
		end

	end

end
