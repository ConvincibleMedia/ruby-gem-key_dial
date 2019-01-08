# HashDial

**Avoid all errors when accessing a deeply nested Hash key.** HashDial goes one step beyond `Hash::dig()` by returning `nil` (or your default) if the keys requested are invalid for any reason.

In particular, if you try to access a key on a value that isn't a hash, `dig()` will cause an error where HashDial will not.

```ruby
hash = {a: {b: {c: true}, d: 5}}
hash.dig( :a, :d, :c) #=> TypeError: Integer does not have #dig method
hash.call(:a, :d, :c) #=> nil
hash.call(:a, :b, :c) #=> true
```

**Bonus: you don't even need to fiddle with existing code.** If you have already written something to access a deep hash key, just surround this with `dial` and `call` (rather than changing it to the form above as function parameters).

```ruby
 hash[:a][:d][:c]           #=> TypeError: no implicit conversion of Symbol into Integer

#hash →   [:a][:d][:c]
#     ↓                ↓
 hash.dial[:a][:d][:c].call #=> nil
```

## Explanation

We use the concept of placing a phone-call: you can 'dial' any set of keys regardless of whether they exist (like entering a phone number), then finally place the 'call'. If the key is invalid for any reason you get nil/default (like a wrong number); otherwise you get the value (you're connected).

This works by intermediating your request with a HashDialler object. Trying to access keys on this object simply builds up a list of keys to use when you later place the 'call'.

## Usage

```ruby
require 'hash_dial'
```

### Use it like dig()

If you want to follow this pattern, it works in the same way. You can't change the default return value when using this pattern.

```ruby
hash.call(:a, :b, :c) # Returns the value at hash[:a][:b][:c] or nil
```

### Use it like a Hash -- allows default return value

```ruby
hash.dial[:a][:b][:c].call          # Returns the value at hash[:a][:b][:c] or nil
hash.dial[:a][:b][:c].call('Ooops') # Returns the value at hash[:a][:b][:c] or 'Ooops'
```

If you don't do this all in one line, you can access the HashDialler object should you want to manipulate it:

```ruby
dialler = hash.dial # Returns a HashDialler object referencing hash
dialler[:a] # Adds :a to the list of keys to dial (returns self)
dialler.dial!(:b, :c) # Longhand way of adding more keys (returns self)
dialler.undial! # Removes the last-added key (returns self)
dialler[:c][:d] # Adds two more keys (returns self)
dialler += :e # Adds yet one more (returns self)
dialler -= :a # Removes all such keys from the list (returns self)
# So far we have dialled [:b][:c][:d][:e]
dialler.call # Returns the value at hash[:b][:c][:d][:e] or nil
dialler.hangup # Returns the original hash by reference
```
