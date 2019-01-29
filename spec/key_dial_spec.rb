RSpec.describe KeyDial do
    it "has a version number" do
        expect(KeyDial::VERSION).not_to be nil
    end

    test_original = {a: {b: {c: true}, d: 5}, e: [0, 1], f: Struct.new(:g).new('hello')}.deep_freeze
    test = test_original.deep_dup

    # Shorthand e.g. hash.dial[a][b]

    it "can be used in shorthand and digs out the correct value" do
        expect(test.dial[:a][:b][:c].call).to eq(true)
        expect(test.dial[:e][1].call).to eq(1)
        expect(test.dial[:f][:g].call).to eq('hello')
    end

    it "can be used in shorthand and returns nil for a nonexistent key" do
        expect(test.dial[:a][:x][:c].call).to eq(nil)
        expect(test.dial[:e][:x][:c].call).to eq(nil)
        expect(test.dial[:f][:x][:c].call).to eq(nil)
    end

    it "can be used in shorthand and returns nil if requesting a key on a non-keyed object" do
        expect(test.dial[:a][:d][:c].call).to eq(nil)
    end

    it "can be used in shorthand and does not mutate the original hash" do
        expect(test).to eq(test_original)
    end

    # Dig e.g. hash.dial(a, b)

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

    # Setting

    it "can set a value on a dialled deep hash key that exists" do
        test.dial[:a][:b][:c] = 'test'
        expect(test[:a][:b][:c]).to eq('test')
    end

    it "can add a value at a dialled deep hash key that does not exist" do
        test.dial[:a][:b][:f] = 'test'
        expect(test[:a][:b][:f]).to eq('test')
    end

    it "can set a value on a dialled deep array key that exists" do
        test.dial[:e][0] = 'test'
        expect(test[:e][0]).to eq('test')
    end

    it "can add a value at a dialled deep array key that does not exist" do
        test.dial[:e][2] = 'test'
        expect(test[:e][2]).to eq('test')
    end

    it "can add a value at a negative array key that does not exist" do
        test.dial[:e][-5] = 'test'
        expect(test[:e][-5]).to eq('test')
    end

    it "can set a value on a dialled deep struct key that exists" do
        test.dial[:f][:g] = 'test'
        expect(test[:f][:g]).to eq('test')
        test.dial[:f][0] = 'test2'
        expect(test[:f][0]).to eq('test2')
    end

    it "can set a value on a negative struct key that does not exist" do
        test.dial[:f][-4] = 'test3'
        expect(test[:f][-4]).to eq('test3')
    end

    it "can add a value at a dialled deep struct key that does not exist" do
        test.dial[:f][:h] = 'test'
        expect(test[:f][:h]).to eq('test')
        test.dial[:f][1] = 'test2'
        expect(test[:f][1]).to eq('test2')
    end

    test = test_original.deep_dup

    it "can change a deep key from array to hash if required" do
        test.dial[:e]['string'] = 'test'
        expect(test.dial[:f]['string'].call('test')).to eq('test')
    end

    it "can create missing hashes or arrays along the way" do
        test.dial[:a][3] = 'test'
        expect(test[:a][3]).to eq('test')
        test.dial[:a][2][:z] = 'test'
        expect(test[:a][2][:z]).to eq('test')
    end

end
