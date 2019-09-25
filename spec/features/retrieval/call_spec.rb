RSpec.describe ".call(..., ...)" do

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
			expect(test.call(:a, :b, :c)).to eq(true)
			expect(test.call(:e, 1)).to eq(1)
			expect(test.call(:f, :g)).to eq('hello')
		end

	end

	context "non-existent key" do

		it "handles non-existent key" do
			expect(test.call(:a, :x, :c)).to eq(nil)
			expect(test.call(:e, :x, :c)).to eq(nil)
			expect(test.call(:f, :x, :c)).to eq(nil)
		end

		it "handles non-keyed object" do
			expect(test.call(:a, :d, :c)).to eq(nil)
			expect(test.call(:e, 1, 1)).to eq(nil)
			expect(test.call(:f, :g, 1)).to eq(nil)
		end
		
	end

	it "does not mutate the original variable" do
		test_dup = test.deep_dup
		test.call(:a, :d, :c)
		expect(test).to eq(test_dup)
	end

end