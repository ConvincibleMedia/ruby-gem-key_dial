require 'hash_dial'

RSpec.describe HashDial do
  it "has a version number" do
    expect(HashDial::VERSION).not_to be nil
  end

  it "digs out the correct value" do
    test = {a: {b: {c: true}, d: 5}}
    expect(test.dial[:a][:b][:c].call).to eq(true)
  end

  it "returns nil for a nonexistent key" do
    test = {a: {b: {c: true}, d: 5}}
    expect(test.dial[:a][:x][:c].call).to eq(HashDial::HashDialler.default)
  end

  it "returns nil if requesting a key on a non-hash" do
    test = {a: {b: {c: true}, d: 5}}
    expect(test.dial[:a][:d][:c].call).to eq(HashDial::HashDialler.default)
  end
end
