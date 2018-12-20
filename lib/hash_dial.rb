require "hash_dial/version"
require "hash_dial/hash_dialler"

module HashDial

    def to_dial
        return HashDialler.new(dup)
    end

    alias_method :dial, :to_dial

end

class Hash
    include HashDial
end
