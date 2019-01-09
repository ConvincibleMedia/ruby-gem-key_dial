# KeyDial (Ruby Gem)

**Avoid all errors when accessing a deeply nested Hash key,** or Array or Struct key. KeyDial goes one step beyond Ruby 2.3's `dig()` method by quietly returning `nil` (or your default) if the keys requested are invalid for any reason, and never an error.

In particular, if you try to access a key on a value that can't have keys, `dig()` will cause an error where KeyDial will not.

```ruby
hash = {a: {b: {c: true}, d: 5}}

hash.dig( :a, :d, :c) #=> TypeError: Integer does not have #dig method
hash.call(:a, :d, :c) #=> nil
hash.call(:a, :b, :c) #=> true
```

**Bonus: you don't even need to fiddle with existing code.** If you have already written something to access a deeply nested key, just surround this with `dial` and `call` (rather than changing it to the form above as function parameters).

```ruby
 hash[:a][:d][:c]           #=> TypeError: no implicit conversion of Symbol into Integer

#hash →   [:a][:d][:c]
#     ↓                ↓
 hash.dial[:a][:d][:c].call #=> nil
```

**KeyDial will work on mixed objects**, such as structs containing arrays containing hashes. It can be called from any hash, array or struct.

## Explanation

We use the concept of placing a phone-call: you can 'dial' any set of keys regardless of whether they exist (like entering a phone number), then finally place the 'call'. If the key is invalid for any reason you get nil/default (like a wrong number); otherwise you get the value (you're connected).

This works by intermediating your request with a KeyDialler object. Trying to access keys on this object simply builds up a list of keys to use when you later place the 'call'. The call then `dig`s for the keys safely.

## Usage

```ruby
require 'hash_dial'
```

### Use it like `dig()`

If you want to follow this pattern, it works in the same way. You can't change the default return value when using this pattern.

```ruby
array = [0, {a: [true, false], b: 'foo'}, 2]

array.call(1, :a, 0) #=> true (i.e. array[1][:a][0])
array.call(1, :b, 0) #=> nil (i.e. array[1][:b][0] doesn't exist)
```

You can `call` on any Hash, Array or Struct after requiring this gem.

Note that KeyDial does not treat strings as arrays. Trying to access a key on a string will return nil or your default. (This is also how `dig()` works.)

### Use key access syntax (allows default return value)

```ruby
hash.dial[:a][4][:c].call          # Returns the value at hash[:a][4][:c] or nil
hash.dial[:a][4][:c].call('Ooops') # Returns the value at hash[:a][4][:c] or 'Ooops'
```

You can `dial` on any Hash, Array or Struct after requiring this gem.

### Use the KeyDialler object

If you don't do this all in one line, you can access the KeyDialler object should you want to manipulate it:

```ruby
dialler = KeyDial::KeyDialler.new(struct) # Returns a KeyDialler object referencing struct
dialler[:a] # Adds :a to the list of keys to dial (returns self)
dialler.dial!(:b, :c) # Longhand way of adding more keys (returns self)
dialler.undial! # Removes the last-added key (returns self)
dialler[:c][:d] # Adds two more keys (returns self)
dialler += :e # Adds yet one more (returns self)
dialler -= :a # Removes all such keys from the list (returns self)
# So far we have dialled [:b][:c][:d][:e]
dialler.call # Returns the value at struct[:b][:c][:d][:e] or nil
dialler.hangup # Returns the original keyed object by reference
```

## Note

KeyDial is a generic version of the gem HashDial, replacing and deprecating it.
