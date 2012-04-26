require "mushroom"

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
  end
end

