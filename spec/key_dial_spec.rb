RSpec.describe KeyDial do
    it "has a version number" do
        expect(KeyDial::VERSION).not_to be nil
    end

    test_original = {a: {b: {c: true}, d: 5}, e: [0, 1]}.freeze
    test = test_original.dup

    # Shorthand i.e. hash.dial[a][b]

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

    # Dig i.e. (a, b)

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
        expect(test.dial[:a][:d][:c].object).to eq(test_original)
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

    # Key.dial

    it "can be created via Keys[], Keys.new" do
        x = Keys[:a]
        expect(x.is_a?(KeyDial::KeyDialler)).to eq(true)
    end

    it "Keys[:a][:b].keys = [:a, :b]" do
        expect(Keys[:a].keys).to eq([:a])
        expect(Keys[:a][:b].keys).to eq([:a, :b])
    end

    it "Keys[:a][:b].object = {}" do
        expect(Keys[:a][:b].object).to eq({})
    end

    it "KeyDialler.object = new_obj (keys already dialled)" do
        x = Keys[:a][:b][:c]
        x.object = test
        expect(x.call).to eq(true)
    end

    # API

    it "can't access KeyDialler.use_keys" do
        x = KeyDial::KeyDialler.new
        expect{x.use_keys(:a, :b, :c)}.to raise_error(NoMethodError)
    end

end
