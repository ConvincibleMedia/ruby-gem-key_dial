RSpec.describe KeyDial do

	it "has a version number" do
		expect(KeyDial::VERSION).not_to be nil
	end

	it "does not expose KeyDialler.use_keys" do
		x = KeyDial::KeyDialler.new
		expect{x.use_keys(:a, :b, :c)}.to raise_error(NoMethodError)
	end

end
