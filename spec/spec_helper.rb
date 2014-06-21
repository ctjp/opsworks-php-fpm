require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
# require 'chefspec/cacher'

RSpec.configure do |config|
  config.log_level = :warn
end

at_exit { ChefSpec::Coverage.report! }
