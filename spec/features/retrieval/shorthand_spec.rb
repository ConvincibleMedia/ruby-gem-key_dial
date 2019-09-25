RSpec.describe ".dial[...][...].call" do

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

	context "existent key" do

		it "digs out the correct value" do
			expect(test.dial[:a][:b][:c].call).to eq(true)
			expect(test.dial[:e][1].call).to eq(1)
			expect(test.dial[:f][:g].call).to eq('hello')
		end

	end

	context "non-existent key" do

		it "handles non-existent key" do
			expect(test.dial[:a][:x][:c].call).to eq(nil)
			expect(test.dial[:e][:x][:c].call).to eq(nil)
			expect(test.dial[:f][:x][:c].call).to eq(nil)
		end

		it "handles non-keyed object" do
			expect(test.dial[:a][:d][:c].call).to eq(nil)
			expect(test.dial[:e][1][1].call).to eq(nil)
			expect(test.dial[:f][:g][1].call).to eq(nil)
		end

	end

	it "does not mutate the original variable" do
		test_dup = test.deep_dup
		test.dial[:a][:d][:c].call
		expect(test).to eq(test_dup)
	end

end