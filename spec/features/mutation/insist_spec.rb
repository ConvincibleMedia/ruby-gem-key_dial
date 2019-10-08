RSpec.describe ".dial[...][...].insist!" do

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
	
		it "returns the value" do
			expect(test.dial[:a][:b][:c].insist!).to eq(true)
		end

		it "can chain with key access" do
			test.dial[:a][:b].insist![:c] = false
			expect(test[:a][:b][:c]).to eq(false)
		end

		it "can chain with hash merge" do
			test.dial[:a][:b].insist!.merge!({c: 'a', h: 'b'})
			expect(test[:a][:b][:c]).to eq('a')
			expect(test[:a][:b][:h]).to eq('b')
		end

	end

	context "non-existent key" do

		context "no type specified" do

			it "creates empty hash at new hash key" do
				expect(test.dial[:a][:e].insist!).to eq({})
			end

			it "creates empty hash at new array element, infilling with nil" do
				test.dial[:e][3].insist!
				expect(test[:e]).to eq([0, 1, nil, {}])
			end

			it "creates empty hash inside deeply nested hash" do
				test.dial[:a][:e][:x][:z].insist!
				expect(test[:a][:e]).to eq({
					x: {
						z: {}
					}
				})
			end

			it "creates empty hash inside deeply nested mixed object" do
				test.dial[:e][3][:x][2][:y].insist!
				expect(test[:e]).to eq([
					0, 1, nil, {
						x: [
							nil, nil, {
								y: {}
							}
						]
					}
				])
			end

		end

		context "type specified" do

			it "creates Hash" do
				test.dial[:a][:e][:x][:z].insist!(Hash)
				expect(test[:a][:e]).to eq({
					x: {
						z: {}
					}
				})
			end

			it "creates Array" do
				test.dial[:a][:e][:x][:z].insist!(Array)
				expect(test[:a][:e]).to eq({
					x: {
						z: []
					}
				})
			end

			it "creates anonymous empty Struct" do
				test.dial[:a][:e][:x][:z].insist!(Struct)
				expect(test[:a][:e][:x][:z]).to be_a(Struct)
				expect(test[:a][:e][:x][:z].members).to eq([:'0'])
				expect(test[:a][:e][:x][:z].values).to eq([nil])
			end

			it "creates specific Struct" do
				test.dial[:a][:e][:x][:z].insist!(Struct::Test)
				expect(test[:a][:e][:x][:z]).to be_a(Struct)
				expect(test[:a][:e][:x][:z]).to eq(Struct::Test.new)
			end

		end
	
	end
	
	context "non-keyed object" do

		it "creates Hash with overwritten object at key 0" do
			expect(test.dial[:a][:b][:c].insist!(Hash)).to eq({0 => true})
			expect(test[:a][:b][:c]).to eq({0 => true})
		end

		it "creates Array with overwritten object as first element" do
			expect(test.dial[:a][:b][:c].insist!(Array)).to eq([true])
			expect(test[:a][:b][:c]).to eq([true])
		end

		it "creates Struct passing overwritten object to constructor" do
			expect(test.dial[:a][:b][:c].insist!(Struct::Test)).to eq(Struct::Test.new(true))
			expect(test[:a][:b][:c]).to eq(Struct::Test.new(true))
		end

	end

	context "coercion between keyed object types" do

		context "to Hash" do

			it "from Array: converts indices to keys" do
				test.dial[:e].insist!(Hash)
				expect(test[:e]).to eq({0 => 0, 1 => 1})
			end

		end

		context "to Array" do

			it "from Struct: converts properties to nested array pairs" do
				test.dial[:f].insist!(Array)
				expect(test[:f]).to eq([[:g, 'hello']])
			end

		end

		context "to anonymous Struct" do

			it "from Hash: converts keys to members" do
				test.dial[:a][:b].insist!(Struct)
				expect(test[:a][:b]).to be_a(Struct)
				expect(test[:a][:b].members).to eq([:c])
				expect(test[:a][:b].values).to eq([true])
			end

		end

	end

end