require 'rspec'
require 'ramen-rails'
require 'hashie/mash'

RSpec.configure do |config|

  config.before :each do
    RamenRails.config.reset!
  end

end
