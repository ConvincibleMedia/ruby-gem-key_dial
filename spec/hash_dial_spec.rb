RSpec.describe HashDial do
    it "has a version number" do
        expect(HashDial::VERSION).not_to be nil
    end

    test_original = {a: {b: {c: true}, d: 5}}.freeze
    test =          {a: {b: {c: true}, d: 5}}

    # Shorthand

    it "can be used in shorthand and digs out the correct value" do
        expect(test.dial[:a][:b][:c].call).to eq(true)
    end

    it "can be used in shorthand and returns nil for a nonexistent key" do
        expect(test.dial[:a][:x][:c].call).to eq(nil)
    end

    it "can be used in shorthand and returns nil if requesting a key on a non-hash" do
        expect(test.dial[:a][:d][:c].call).to eq(nil)
    end

    it "can be used in shorthand and does not mutate the original hash" do
        expect(test).to eq(test_original)
    end

    # Dig

    it "can be used like dig() and digs out the correct value" do
        expect(test.dial(:a, :b, :c).call).to eq(true)
    end

    it "can be used like dig() and returns nil for a nonexistent key" do
        expect(test.dial(:a, :x, :c).call).to eq(nil)
    end

    it "can be used like dig() and returns nil if requesting a key on a non-hash" do
        expect(test.dial(:a, :d, :c).call).to eq(nil)
    end

    it "can be used like dig() and does not mutate the original hash" do
        expect(test).to eq(test_original)
    end

    # Instant call

    it "can be call()ed directly and digs out the correct value" do
        expect(test.call(:a, :b, :c)).to eq(true)
    end

    it "can be call()ed directly and returns nil for a nonexistent key" do
        expect(test.call(:a, :x, :c)).to eq(nil)
    end

    it "can be call()ed directly and returns nil if requesting a key on a non-hash" do
        expect(test.call(:a, :d, :c)).to eq(nil)
    end

    it "can be call()ed directly and does not mutate the original hash" do
        expect(test).to eq(test_original)
    end

    # Other operators

    it "can work with +" do
        expect((test.dial[:a][:b] + :c).call).to eq(true)
    end

    it "can work with -" do
        expect((test.dial[:a][:d][:x] - :x).call).to eq(5)
    end

    # Undial

    it "can remove the last key with undial!" do
        expect(test.dial[:a][:d][:x].undial!.call).to eq(5)
    end

    # Custom default

    it "returns a custom default" do
        expect(test.dial[:a][:d][:c].call('test')).to eq('test')
    end

    # Hangup

    it "can hangup i.e. stop dialing and return original hash" do
        expect(test.dial[:a][:d][:c].hangup).to eq(test_original)
    end

    it "handles original hash by reference" do
        dial = test.dial[:a][:b][:d]
        test[:a][:b][:d] = 10
        expect(dial.call).to eq(10)
    end

    it "returns original hash by reference" do
        dial = test.dial[:a][:b][:d]
        dial.hangup[:a][:b][:d] = 20
        expect(test[:a][:b][:d]).to eq(20)
    end

end
