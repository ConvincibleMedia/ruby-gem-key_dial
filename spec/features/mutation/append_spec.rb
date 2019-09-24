RSpec.describe ".dial[...][...] << ..." do

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

	context "Array" do

		it "appends value to an array" do
			test.dial[:e] << 'test'
			expect(test[:e]).to eq([
				0, 1, 'test'
			])
		end

	end

	context "non-existent key" do

		it "creates an array" do
			test.dial[:a][:g] << 'test'
			expect(test[:a][:g]).to eq(['test'])
		end

	end

	context "Hash" do

		it "adds numbered key" do
			test.dial[:a][:b] << 'test'
			expect(test[:a][:b]).to eq({
				c: true,
				1 => 'test'
			})
		end

		it "adds next numbered key" do
			test.dial[:a][:b] << 'a'
			test.dial[:a][:b] << 'b'
			expect(test[:a][:b]).to eq({
				c: true,
				1 => 'a',
				2 => 'b'
			})
		end

	end

	context "other non-array" do

		it "encapsulates object in new array and appends value" do
			test.dial[:a][:d] << 'test'
			expect(test[:a][:d]).to eq([
				5, 'test'
			])
		end

	end

end