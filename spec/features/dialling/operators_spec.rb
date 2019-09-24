RSpec.describe ".dial[...][...] +/- ..." do

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

	context "key addition (+)" do

		it 'dials key' do
			dial = test.dial[:a][:b] + :c
			expect(dial.call).to eq(true)
		end

	end

	context "key subtraction (-)" do

		it 'removes key from end' do
			dial = test.dial[:a][:d][:x] - :x
			expect(dial.call).to eq(5)
		end

		it 'removes key from middle' do
			dial = test.dial[:a][:x][:b][:c] - :x
			expect(dial.call).to eq(true)
		end
		
	end

end