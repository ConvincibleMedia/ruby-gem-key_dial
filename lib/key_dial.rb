require "key_dial/version"
require "key_dial/key_dialler"

module KeyDial

    DEFAULT_OBJECT = {}

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

    module Static
        def dial(object = self, *lookup)
            return KeyDial::KeyDialler.new(nil, *lookup)
        end
    end

end

# Extend core classes so that .dial can be called seamlessly
# Hash.new.dial = instance method on this hash object
# Hash.dial = static method to create an empty KeyDialler object
class Hash
    include KeyDial
    extend KeyDial::Static
end

class Array
    include KeyDial
    extend KeyDial::Static
end

class Struct
    include KeyDial
    extend KeyDial::Static
end

# For static invokation when you don't care about which object you're invoking on
module Keys
    extend KeyDial::Static
    def self.new; return KeyDial::DEFAULT_OBJECT; end
end
