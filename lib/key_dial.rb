require "key_dial/version"
require "key_dial/key_dialler"
require "key_dial/coercion"

module KeyDial

	# Called on a Hash, Array or Struct, returns a KeyDialler object, ready to dial keys against that Hash, Array or Struct.
	#
	# @param lookup Parameters to this method form initial keys to dial. This is unnecessary but works anyway. For simplicity, dial keys by accessing them as if KeyDialler were a keyed object itself.
	#
	def to_dial(*lookup)
		return KeyDialler.new(self, *lookup)
	end

	alias_method :dial, :to_dial

	# Called directly on a keyed object, immediately dials and calls the keys specified as arguments. Returns the value found, or nil. A default cannot be specified.
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

	# Returns true if this Array has the specified index.
	def key?(key_obj)
		if key_obj.is_a?(Numeric) && key_obj.respond_to?(:to_i)
			key = key_obj.to_i
			return key.magnitude + (key <= -1 ? 0 : 1) <= self.size
		else
			return false
		end
	end if !method_defined?(:key?)

	# Returns an Array of all the valid indices for this Array
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
			# Does the struct have the identified key?
			return self.members.include?(key)
		elsif key.is_a?(Integer)
			# Does the struct have this numbered key?
			return key.magnitude + (key <= -1 ? 0 : 1) <= self.size
		end
	end if !method_defined?(:key?)

	# Extend Struct to give it a fetch method
	def fetch(key_obj, default = (default_skipped = true; nil))
		if key?(key_obj)
			# Use key? method to check this struct has the requested key
			# key? method ensures that key_obj is valid inside struct[key] syntax
			return self[key_obj]
		else
			# Struct doesn't contain this key - proceed to defaults
			if block_given?
				# Warn if both block and default supplied
				warn 'warning: block supersedes default value argument' if !default_skipped
				# Return result of block as default
				return yield(key_obj)
			elsif !default_skipped
				return default
			else
				raise KeyError, "key not found: #{key_obj.to_s}"
			end
		end
	end if !method_defined?(:fetch)

	alias :keys :members

	# Structs are not empty by definition
	def empty?; false; end

end

# Ability to create anonymous key lists (on no particular object) with Keys[a][b][c]
module Keys

	class Missing; end
	MISSING = Missing.new.freeze
	MISSING.freeze

	# Create a new key list (KeyDialler) object using the syntax Keys[...][...]
	def self.[](first_key)
		return KeyDial::KeyDialler.new(nil, first_key)
	end

	# Checks if a key is a valid numeric index, i.e. can be used in the syntax object[index]
	#
	# @param key The key to check.
	#
	# @return True if the key is a valid numeric index, otherwise false.
	#
	def self.index?(key)
		return key.is_a?(Numeric) && key.respond_to?(:to_i)
	end

end