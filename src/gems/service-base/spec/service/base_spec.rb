RSpec.describe Service::Base do
  it "has a version number" do
    expect(Service::Base::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
