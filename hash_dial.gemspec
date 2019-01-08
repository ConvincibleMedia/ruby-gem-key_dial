
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hash_dial/version"

Gem::Specification.new do |spec|
    spec.name          = "hash_dial"
    spec.version       = HashDial::VERSION
    spec.authors       = ["Convincible"]
    spec.email         = ["development@convincible.media"]

    spec.summary       = "Access (deeply nested) hash keys. Get the value, or nil on any error. (Even safer than Hash::dig)."
    spec.description   = "Avoid all errors when accessing (deeply nested) Hash keys. Safer than dig(), as will quietly return nil (or your default) if the keys requested are invalid for any reason at all. Bonus: you don't even need to fiddle with existing code. If you have already written something to access a deep hash key (e.g. hash[:a][:b][:c]), just surround this with '.dial' and '.call'."
    spec.homepage      = "https://github.com/ConvincibleMedia/ruby-gem-hash_dial"

    # Specify which files should be added to the gem when it is released.
    # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
    spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
        `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
    spec.bindir        = "exe"
    spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
    spec.require_paths = ["lib"]
    spec.required_ruby_version = '~> 2.3'

    spec.add_development_dependency "bundler", "~> 1.17"
    spec.add_development_dependency "rake", "~> 10.0"
    spec.add_development_dependency "rspec", "~> 3.0"
end
