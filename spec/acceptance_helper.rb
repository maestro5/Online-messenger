require 'spec_helper'
require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

Capybara.app = eval('Rack::Builder.new {( ' + File.read( + './config.ru') + "\n )}")

RSpec.configure do |config|
  config.include Capybara::DSL
end

def app() Capybara.app end
