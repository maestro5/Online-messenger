require 'spec_helper'

RSpec.describe Message do
  describe '.clear_timeout!' do
    it 'should delete time out message' do
      last_message_time = Time.now + 1.hour
      (0..4).each do
        last_message_time -= 20.minutes
        create(:message, destruction: 'timeout', deadline_at: last_message_time)
      end
      expect { Message.clear_timeout! }.to change(Message, :count).by(-3)
    end
  end # clear_timeout!

  context 'AES algorithm encrypting' do
    let(:msg_title) { 'Test message' }
    let(:msg_body) { 'Test message body' }
    let(:message) { Message.new(title: '', body: '') }

    describe '#encrypt!' do
      it 'when title is empty, return false' do
        message.body = msg_body
        expect(message.encrypt!).to eq false
      end

      it 'when body is empty, return false' do
        message.title = msg_title
        expect(message.encrypt!).to eq false
      end

      it 'when encrypting a message' do
        message.title = msg_title
        message.body  = msg_body

        message.encrypt!
        expect(message.title).not_to be_nil
        expect(message.body).not_to be_nil
        expect(message.title).not_to eq msg_title
        expect(message.body).not_to eq msg_body
      end

      it 'when repeatedly encryp' do
        message.title = msg_title
        message.body  = msg_body
        message.encrypt!
        message_backup = message.dup

        message.encrypt!
        expect(message.secure_id).to eq message_backup.secure_id
        expect(message.key).to eq message_backup.key
        expect(message.title).not_to eq message_backup.title
        expect(message.body).not_to eq message_backup.body
      end
    end # encrypt!

    describe '#decrypt!' do
      it 'when title is empty' do
        message.body = msg_body
        expect(message.decrypt!).to eq false
      end
      it 'when body is emtpy' do
        message.title = msg_title
        expect(message.decrypt!).to eq false
      end
      it 'when key is empty' do
        message.title = msg_title
        message.body  = msg_body
        expect(message.decrypt!).to eq false
      end
      it 'when decrypting a message' do
        message.title = msg_title
        message.body  = msg_body
        message.encrypt!

        expect(message.decrypt!).not_to be false
        expect(message.title).to eq msg_title
        expect(message.body).to eq msg_body
      end
    end # decrypt!
  end # AES algorithm encrypting

  context 'self-destruction' do
    describe '#delete_by_timeout!' do
      let(:message) { create(:message, destruction_value: 2) }

      it { expect(message.delete_by_timeout!).to be false }
      it 'when removing' do
        message.update_attribute(:destruction, 'timeout')
        message.decrypt!
        message.update_attribute(:deadline_at,
          message.deadline_at - message.destruction_value.hour - 1.minute)
        message.decrypt!
        expect { message.delete_by_timeout! }.to change(Message, :count).by(-1)
      end
    end # delete_by_timeout!

    describe '#delete_by_visits!' do
      let(:message) do
        create(:message, destruction: 'visits', destruction_value: 2,
          owner_session_id: 'owner', visits: 2)
      end
      it 'when self-destriction is time out' do
        message.update_attribute(:destruction, 'timeout')
        expect(message.delete_by_visits!('owner')).to be false
      end
      it 'when owner session' do
        expect(message.delete_by_visits!('owner')).to be false
      end
      it 'when removing' do
        message.update_attribute(:visits, 3)
        expect(message.delete_by_visits!('')).to be true
      end
    end # delete_by_visits!
  end # self-destruction

  describe '#owner?' do
    let(:message) { create(:message) }

    it { expect(message.owner?('owner')).to be false }
    it 'when owner' do
      message.update_attribute(:owner_session_id, 'owner')
      expect(message.owner?('owner')).to be true
    end
  end # owner?
end # Message
