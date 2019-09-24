RSpec.describe KeyDial::Coercion do

	describe KeyDial::Coercion::Hashes do

		describe ".to_struct" do

			it "creates anonymous Struct matching keys and values of Hash" do
				hash = {
					a: 1,
					b: 2,
					c: 3
				}
				struct_a = hash.to_struct
				struct_b = Struct.new(:a, :b, :c).new(1, 2, 3)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end

			it "creates specific Struct using values where keys match" do
				Struct.new('Test', :a, :b, :c)
				hash = {
					x: 3,
					b: 2,
					a: 1
				}
				struct_a = hash.to_struct(Struct::Test)
				struct_b = Struct::Test.new(1, 2, 3)
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq([1, 2, nil])
			end

			it "creates empty specific Struct if passed empty Hash" do
				Struct.new('Test', :a, :b, :c)
				hash = {}
				struct_a = hash.to_struct(Struct::Test)
				struct_b = Struct::Test.new(nil, nil, nil)
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end
			
		end

	end

	describe KeyDial::Coercion::Arrays do

		describe ".to_hash" do

			it "converts indices to keys" do
				array = [1, 2, 3]
				expect(array.to_hash).to eq({
					0 => 1,
					1 => 2,
					2 => 3
				})
			end

			it "converts nested keyval pairs" do
				array = [
					['a', 1],
					['b', 2],
					['c', 3]
				]
				expect(array.to_hash).to eq({
					'a' => 1,
					'b' => 2,
					'c' => 3
				})
			end

			it "interprets empty hash as nil" do
				array = [[], [], 'test']
				expect(array.to_hash).to eq({
					0 => nil,
					1 => nil,
					2 => 'test'
				})
			end

			it "assumes anything other than a keyval pair is a value against a numbered key" do
				array = ['a', 'b', ['c', 'd', 'e'], ['f', 'g'], 'h']
				expect(array.to_hash).to eq({
					0 => 'a',
					1 => 'b',
					2 => ['c', 'd', 'e'],
					'f' => 'g',
					4 => 'h'
				})
			end
		
		end

		describe ".to_struct" do

			it "creates anonymous Struct using indices as keys" do
				array = ['a', 'b', 'c']
				struct_a = array.to_struct
				struct_b = Struct.new(:'0', :'1', :'2').new('a', 'b', 'c')
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end
			
			
			it "creates specific Struct, filling in its values sequentially" do
				Struct.new('Test', :a, :b, :c)
				array = [
					1, '2', [:'3'], 4
				]
				struct_a = array.to_struct(Struct::Test)
				struct_b = Struct::Test.new(1, '2', [:'3'])
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end

			it "creates empty specific Struct if passed empty Array" do
				Struct.new('Test', :a, :b, :c)
				array = []
				struct_a = array.to_struct(Struct::Test)
				struct_b = Struct::Test.new(nil, nil, nil)
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end
		
		end

	end

end