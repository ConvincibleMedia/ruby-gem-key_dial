RSpec.describe KeyDial::Coercion do

	Struct.new('Test', :a, :b, :c)

	describe KeyDial::Coercion::Hashes do

		describe ".to(Hash)" do

			it "aliases .to_h" do
				expect{
					expect({a: 1}.to(Hash)).to eq({a: 1}.to_h)
				}.not_to raise_error
			end

		end

		describe ".to(Array)" do

			it "aliases .to_a" do
				expect{
					expect({a: 1}.to(Array)).to eq({a: 1}.to_a)
				}.not_to raise_error
			end

		end

		describe ".to(Struct)" do

			it "creates anonymous Struct matching keys and values of Hash" do
				hash = {
					a: 1,
					b: 2,
					c: 3
				}
				struct_a = hash.to(Struct)
				struct_b = Struct.new(:a, :b, :c).new(1, 2, 3)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end

			it "creates specific Struct using values where keys match" do
				hash = {
					x: 3,
					b: 2,
					a: 1
				}
				struct_a = hash.to(Struct::Test)
				struct_b = Struct::Test.new(1, 2, 3)
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq([1, 2, nil])
			end

			it "creates empty specific Struct if passed empty Hash" do
				hash = {}
				struct_a = hash.to(Struct::Test)
				struct_b = Struct::Test.new(nil, nil, nil)
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end
			
		end

	end

	describe KeyDial::Coercion::Arrays do

		describe ".to(Hash)" do

			it "converts indices to keys" do
				array = [1, 2, 3]
				expect(array.to(Hash)).to eq({
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
				expect(array.to(Hash)).to eq({
					'a' => 1,
					'b' => 2,
					'c' => 3
				})
			end

			it "interprets empty hash as nil" do
				array = [[], [], 'test']
				expect(array.to(Hash)).to eq({
					0 => nil,
					1 => nil,
					2 => 'test'
				})
			end

			it "assumes anything other than a keyval pair is a value against a numbered key" do
				array = ['a', 'b', ['c', 'd', 'e'], ['f', 'g'], 'h']
				expect(array.to(Hash)).to eq({
					0 => 'a',
					1 => 'b',
					2 => ['c', 'd', 'e'],
					'f' => 'g',
					4 => 'h'
				})
			end
		
		end

		describe ".to(Array)" do

			it "aliases .to_a" do
				expect{
					expect([0, 1].to(Array)).to eq([0, 1].to_a)
				}.not_to raise_error
			end

		end

		describe ".to(Struct)" do

			it "creates anonymous Struct using indices as keys" do
				array = ['a', 'b', 'c']
				struct_a = array.to(Struct)
				struct_b = Struct.new(:'0', :'1', :'2').new('a', 'b', 'c')
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end
			
			
			it "creates specific Struct, filling in its values sequentially" do
				array = [
					1, '2', [:'3'], 4
				]
				struct_a = array.to(Struct::Test)
				struct_b = Struct::Test.new(1, '2', [:'3'])
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end

			it "creates empty specific Struct if passed empty Array" do
				array = []
				struct_a = array.to(Struct::Test)
				struct_b = Struct::Test.new(nil, nil, nil)
				expect(struct_a).to be_a(Struct::Test)
				expect(struct_a.members).to eq(struct_b.members)
				expect(struct_a.values).to eq(struct_b.values)
			end
		
		end

	end

	describe KeyDial::Coercion::Structs do

		before(:each) { @struct = Struct.new(:c, :x, :b).new(1, 2, 3) }

		describe ".to(Array)" do

			it "aliases .to_h.to_a" do
				expect{
					expect(@struct.to(Array)).to eq(@struct.to_h.to_a)
				}.not_to raise_error
			end

		end

		describe ".to(Hash)" do

			it "aliases .to_h" do
				expect{
					expect(@struct.to(Hash)).to eq(@struct.to_h)
				}.not_to raise_error
			end

		end

		describe ".to(Struct)" do

			it "returns itself if no specific Struct requested" do
				expect{
					expect(@struct.to(Struct)).to be(@struct)
				}.not_to raise_error
			end

			it "converts into specific Struct requested" do
				expect{
					@struct = @struct.to(Struct::Test)
				}.not_to raise_error
				expect(@struct.members).to eq([:a, :b, :c])
				expect(@struct.values).to eq([nil, 3, 1])
			end

		end

	end

	describe "KeyDial::Coercion::Structs::EMPTY" do

		it "returns the EMPTY struct if passed empty variable" do
			hash = {}; array = []
			struct_a = hash.to(Struct)
			struct_b = array.to(Struct)
			struct_c = Struct.from(nil)
			expect(struct_a).to be(Struct::EMPTY)
			expect(struct_b).to be(struct_a)
			expect(struct_c).to be(struct_a)
			expect(struct_a == Struct::EMPTY).to eq(true)
		end

	end

end