RSpec.describe ".dial[...][...].call(default)" do

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

	let(:default) { 'test' }

	describe "default value" do

		it "returns default" do
			expect(test.dial[:a][:x][:c].call(default)).to eq(default)
			expect(test.dial[:e][:x][:c].call(default)).to eq(default)
			expect(test.dial[:f][:x][:c].call(default)).to eq(default)
		end

	end

	describe "block" do

		context "existent key" do

			it "runs block" do
				ran_block = false
				test.dial[:a][:d].call {
					ran_block = true
				}
				expect(ran_block).to eq(true)
			end

			it "sends retrieved value to block" do
				ran_block = false
				test.dial[:a][:d].call { |x|
					ran_block = x
				}
				expect(ran_block).to eq(5)
			end

		end
	
		context "non-existent key" do

			it "does not run block" do
				ran_block = false
				test.dial[:a][:x].call {
					ran_block = true
				}
				expect(ran_block).to eq(false)
			end

		end

	end

end