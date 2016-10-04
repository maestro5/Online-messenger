require 'spec_helper'

RSpec.describe 'WebsiteController' do
  def app() Sinatra::Application end

  context 'Create new message' do
    describe 'GET \'/message/create\'' do
      it 'loads create form' do
        get '/message/create'
        expect(last_response).to be_ok
        expect(last_response.body).to include 'Create Message'
      end
    end # GET /message/create

    describe 'POST \'/message\'' do
      it 'when invalid title' do
        post '/message',
          message: { title: '', body: 'Test message body', destruction: 'visits' },
          destruction: { visits: '1', timeout: '1' }
        expect(last_response).to be_ok
        expect(last_request.path).to eq '/message'
        expect(last_response.body).to include 'Create Message'
      end
      it 'when invalid (short) title' do
        post '/message',
          message: { title: 'Test', body: 'Test message body', destruction: 'visits' },
          destruction: { visits: '1', timeout: '1' }
        expect(last_response).to be_ok
        expect(last_request.path).to eq '/message'
        expect(last_response.body).to include 'Create Message'
      end
      it 'when invalid body' do
        post '/message',
          message: { title: 'Test message title', body: '', destruction: 'visits' },
          destruction: { visits: '1', timeout: '1' }
        expect(last_response).to be_ok
        expect(last_request.path).to eq '/message'
        expect(last_response.body).to include 'Create Message'
      end
      it 'when valid' do
        post '/message',
          message: { title: 'Test message title', body: 'Test message body', destruction: 'visits' },
          destruction: { visits: '1', timeout: '1' }
        expect(last_response.redirect?).to be true
        follow_redirect!
        expect(last_response.body).to include 'Message created'
        expect(last_response.body).to include 'Test message title'
        expect(last_response.body).to include 'Test message body'
      end
    end # POST /message
  end # Create new message

  describe 'GET \'/message/:secure_id\'' do
    let(:message) { create(:message).decrypt! }
    it 'when visit 1' do
      expect { get "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
      expect(last_response).to be_ok
      expect(last_response.body).to include message.title
      expect(last_response.body).to include message.body
    end
    it 'when visit 2' do
      message.update_attribute(:visits, 1)
      expect { get "/message/#{message.secure_id}" }
        .to change(Message, :count).by(-1)
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_request.path).to eq '/'
    end
  end # GET /message/:secure_id

  context 'Edit' do
    let(:message) { create(:message) }

    describe 'GET \'/message/:secure_id/edit\'' do
      it 'when not owner' do
        get "/message/#{message.secure_id}/edit"
        expect(last_response.redirect?).to be true
        follow_redirect!
        expect(last_request.path).to eq '/'
      end
    end # GET /message/:secure_id/edit

    describe 'PUT \'/message/:secure_id\'' do
      it 'when not owner' do
        put "/message/#{message.secure_id}"
        expect(last_response.redirect?).to be true
        follow_redirect!
        expect(last_request.path).to eq '/'
      end
    end # PUT /message/:secure_id
  end # Edit

  describe 'DELETE \'/message/:secure_id\'' do
    it 'when not owner' do
      message = create(:message)
      expect { delete "/message/#{message.secure_id}" }.not_to change(Message, :count)
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_request.path).to eq '/'
    end
  end # DELETE /messge/:secure_id
end # WebsiteController
