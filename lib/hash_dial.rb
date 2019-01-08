require "hash_dial/version"
require "hash_dial/hash_dialler"

module HashDial

    # Called on a Hash, returns a HashDialler object for that Hash.
    #
    # @param lookup Parameters to this method form initial hash keys to dial. This is unnecessary but works anyway. For simplicity, dial hash keys by accessing them as if HashDialler were a Hash.
    #
    def to_dial(*lookup)
        return HashDialler.new(self, *lookup)
    end

    alias_method :dial, :to_dial

    # Called directly on a Hash, immediately dials and calls the hash keys specified as arguments. Returns the value found, or nil.
    #
    # @param lookup The hash keys to attempt to retrieve.
    #
    def call(*lookup)
        return HashDialler.new(self, *lookup).call
    end

end

# Extend core class so that hash.dial can be called
class Hash
    include HashDial
end
