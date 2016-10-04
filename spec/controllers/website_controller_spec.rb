require 'spec_helper'

RSpec.describe 'WebsiteController' do
  def app() Sinatra::Application end

  describe 'GET \'/\'' do
    it 'loads home page' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Welcome')
      expect(last_response.body).to include('Online messenger')
    end
  end # GET '/'

  describe 'GET \'not_found\'' do
    it 'redirect to home page' do
      get '/some'
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_request.path).to eq '/'
    end
  end # GET 'not_found'
end # WebsiteController
