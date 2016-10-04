require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'sinatra/flash'
require 'securerandom'
require 'aes'
require 'rufus-scheduler'
require './lib/sinatra/style'
require './models/message'
require './helpers/website_helpers'
require './controllers/website_controller'
require './controllers/message_controller'

enable :sessions

helpers WebsiteHelpers

# ---------------------------------
# removal of overdue messages
# ---------------------------------
scheduler = Rufus::Scheduler.new
scheduler.every '3h' do
  Message.clear_timeout!
end
