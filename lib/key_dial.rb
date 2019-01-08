require "hash_dial/version"
require "hash_dial/hash_dialler"

module KeyDial

    # Called on a Hash, Array or Struct, returns a KeyDialler object.
    #
    # @param lookup Parameters to this method form initial keys to dial. This is unnecessary but works anyway. For simplicity, dial keys by accessing them as if KeyDialler were a keyed object itself.
    #
    def to_dial(*lookup)
        return KeyDialler.new(self, *lookup)
    end

    alias_method :dial, :to_dial

    # Called directly on a keyed object, immediately dials and calls the keys specified as arguments. Returns the value found, or nil.
    #
    # @param lookup The keys to attempt to retrieve.
    #
    def call(*lookup)
        return KeyDialler.new(self, *lookup).call
    end

end

# Extend core class so that .dial can be called seamlessly
class Hash
    include KeyDial
end

class Array
    include KeyDial
end

class Struct
    include KeyDial
end
