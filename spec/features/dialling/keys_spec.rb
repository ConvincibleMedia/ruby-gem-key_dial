RSpec.describe Keys do

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
	
	describe "Keys.new" do

		it "can be created via Keys[...]" do
			x = Keys[:a]
			expect(x.is_a?(KeyDial::KeyDialler)).to eq(true)
		end

		it "initialises on empty hash" do
			expect(Keys[:a][:b].object).to eq({})
		end

	end

	describe ".keys" do

		it "returns an array of dialled keys" do
			expect(Keys[:a].keys).to eq([:a])
			expect(Keys[:a][:b].keys).to eq([:a, :b])
		end

	end

	it "can be attached to an object after keys are dialled" do
		dial = Keys[:f][:g]
		dial.object = test
		expect(dial.call).to eq('hello')
	end

end