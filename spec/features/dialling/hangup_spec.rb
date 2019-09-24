RSpec.describe ".hangup" do

	let(:test) do
		{
			a: {
				b: {
					c: true
				},
				d: 5
			},
			e: [0, 1],
			f: Struct.new(:g).new('hello')
		}
	end

	it "returns original object" do
		expect(test.dial[:a][:d][:c].hangup).to be(test)
	end

	it "lets you access original object" do
		expect(test.dial[:a][:d][:c].object).to be(test)
	end

	it "does not act on a duplicate of the original object" do
		dial = test.dial[:a][:b][:d] # Dial non-existent key
		test[:a][:b][:d] = 10 # Set that directly on original object
		expect(dial.call).to eq(10) # Now call the key
	end

	it "does not return a duplicate of the original object" do
		dial = test.dial[:a][:b][:d]
		dial.hangup[:a][:b][:d] = 20
		expect(test[:a][:b][:d]).to eq(20)
	end

end