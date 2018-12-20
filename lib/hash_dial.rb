require "hash_dial/version"
require "hash_dial/hash_dialler"

module HashDial

    def to_dial(*lookup)
        return HashDialler.new(self, *lookup)
    end

    alias_method :dial, :to_dial

    def call(*lookup)
        return HashDialler.new(self, *lookup).call
    end

end

class Hash
    include HashDial
end
