RSpec.describe ".dial[...][...] = ..." do

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

	context "Hash" do

		context "existent key" do

			it "sets value" do
				test.dial[:a][:b][:c] = 'test'
				expect(test[:a][:b][:c]).to eq('test')
			end

		end
		
		context "non-existent key" do

			it "adds a new key" do
				test.dial[:a][:b][:f] = 'test'
				expect(test[:a][:b][:f]).to eq('test')
			end

		end
	
	end

	context "Array" do

		context "existent key" do

			it "sets value by index" do
				test.dial[:e][0] = 'test'
				expect(test[:e][0]).to eq('test')
			end

			context "negative index" do

				it "sets the correct element" do
					test.dial[:e][-1] = 'test'
					expect(test[:e]).to eq([
						0, 'test'
					])
				end
			
			end
		
		end

		context "non-existent key" do

			context "next index" do
			
				it "adds a new element" do
					test.dial[:e][2] = 'test'
					expect(test[:e]).to eq([
						0, 1, 'test'
					])
				end

			end

			context "distant index" do

				it "adds a new element, infilling with nil" do
					test.dial[:e][5] = 'test'
					expect(test[:e]).to eq([
						0, 1, nil, nil, nil, 'test'
					])
				end

			end

			context "negative index" do

				it "prepends array with nil, and sets first value" do
					test.dial[:e][-5] = 'test'
					expect(test[:e]).to eq([
						'test', nil, nil, 0, 1
					])
				end
			
			end

		end

	end

	context "Struct" do

		context "existent key" do
			
			it "sets value" do
				test.dial[:f][:g] = 'test'
				expect(test[:f][:g]).to eq('test')
			end

			context "by index" do
			
				it "sets value" do
					test.dial[:f][0] = 'test2'
					expect(test[:f][0]).to eq('test2')
				end

			end

		end

		context "non-existent key" do

			it "redefines struct with new key" do
				test.dial[:f][:h] = 'test'
				expect(test[:f].members).to eq([:g, :h])
				expect(test[:f].values).to eq(['hello', 'test'])
			end

			context "by index" do

				it "redfines struct and sets value" do
					test.dial[:f][1] = 'test'
					expect(test[:f].members).to eq([:g, :'1'])
					expect(test[:f].values).to eq(['hello', 'test'])
				end

				context "negative index" do

					it "redefines struct prepending with nil, and sets value" do
						test.dial[:f][-4] = 'test'
						expect(test[:f].members).to eq([:'0', :'1', :'2', :g])
						expect(test[:f].values).to eq(['test', nil, nil, 'hello'])
					end

				end

			end

		end

	end

	it "can create a deeply nested object of hashes or arrays appropriate to keys requested" do
		test.dial[:a][:b][:f][:g][:h][3][:k] = 'test'
		expect(test[:a][:b][:f]).to eq({
			g: {
				h: [
					nil,
					nil,
					nil,
					{
						k: 'test'
					}
				]
			}
		})
	end

	describe "coercion" do

		it "can change a deep key from array to hash if required" do
			expect(test[:e].is_a?(Array)).to eq(true)
			test.dial[:e]['string'] = 'test3'
			expect(test[:e].is_a?(Hash)).to eq(true)
			expect(test[:e]['string']).to eq('test3')
		end

	end

end