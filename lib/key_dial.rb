require "key_dial/version"
require "key_dial/key_dialler"
require "key_dial/coercion"

module KeyDial

    DEFAULT_OBJECT = {}.freeze

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

# Extend core classes so that .dial can be called seamlessly
class Hash
    include KeyDial
    include KeyDial::Coercion::Hashes
end

# Bring Array and Struct into parity with Hash for key? and fetch
# Will not redefine these methods if they already exist, either from some future Ruby version or another gem

class Array
    include KeyDial
    include KeyDial::Coercion::Arrays

    # Extend Array to give it a key? method
    def key?(key_obj)
        if key_obj.is_a?(Numeric) && key_obj.respond_to?(:to_i)
            key = key_obj.to_i
            return key.magnitude + (key <= -1 ? 0 : 1) <= self.size
        else
            return false
        end
    end if !method_defined?(:key?)

    def keys
        if self.size > 0
            return Array(0..(self.size - 1))
        else
            return []
        end
    end

    alias :values :to_ary

end

class Struct
    include KeyDial
    include KeyDial::Coercion::Structs

    # Extend Struct to give it a key? method
    def key?(key_obj)
        # These would be valid keys in struct[key] syntax
        if key_obj.is_a?(Symbol)
            key = key_obj
        elsif key_obj.is_a?(String)
            key = key_obj.to_sym
        elsif key_obj.is_a?(Numeric) && key_obj.respond_to?(:to_i)
            key = key_obj.to_i
        else
            return false #raise TypeError, "no implicit conversion of #{key_obj.class} into Symbol"
        end

        if key.is_a?(Symbol)
            return self.members.include?(key)
        elsif key.is_a?(Integer)
            return key.magnitude + (key <= -1 ? 0 : 1) <= self.size
        end
    end if !method_defined?(:key?)

    # Extend Struct to give it a fetch method
    def fetch(key_obj, default = (default_skipped = true; nil))
        if key?(key_obj)
            # key? method ensures that key_obj is valid inside struct[key] syntax
            return self[key_obj]
        else
            if block_given?
                warn 'warning: block supersedes default value argument' if !default_skipped
                return yield(key_obj)
            elsif !default_skipped
                return default
            else
                raise KeyError, "key not found: #{key_obj.to_s}"
            end
        end
    end if !method_defined?(:fetch)

    alias :keys :members

end

# Ability to create anonymous key lists (on no particular object) with Keys[a][b][c]
module Keys

    class NullKey; end
    NULL = NullKey.new.freeze

    def self.[](first_key)
        return KeyDial::KeyDialler.new(nil, first_key)
    end

end
