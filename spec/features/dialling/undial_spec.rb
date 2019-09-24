RSpec.describe ".undial!" do

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

	it "removes the last key" do
		dial = test.dial[:a][:d][:x]
		dial.undial!
		expect(dial.call).to eq(5)
	end
	
	it "removes inside keys" do
		dial = test.dial[:a][:x][:e][:x][:y][1]
		dial.undial!(:a, :x, :y)
		expect(dial.call).to eq(1)
	end

end