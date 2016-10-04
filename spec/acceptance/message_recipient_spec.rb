require_relative '../acceptance_helper'

feature 'Guest', %q{
  As a guest (not owner)
  I want to be able to visit a message
} do

  # -----------------------------------
  # visits
  # -----------------------------------
  context 'when message self-destruction by visits' do
    scenario 'after given number of link visits' do
      message = create(:message, destruction_value: 2)
      message.decrypt!

      # visit 1
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      # visit 2
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      # visit 3
      expect { visit "/message/#{message.secure_id}" }
        .to change(Message, :count).by(-1)
      expect(current_path).to eq '/'
      expect(page).to have_content 'Invalid message url!'
    end # after given number of link visits

    scenario 'after edited from \'timeout\' to \'visits\'' do
      message = create(:message, destruction: 'timeout')
      message.decrypt!

      # visit 1, time is not over
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      message.update_attributes(destruction: 'visits', destruction_value: 2)
      message.decrypt!

      # visit 2
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      # visit 3
      expect { visit "/message/#{message.secure_id}" }
        .to change(Message, :count).by(-1)
      expect(current_path).to eq '/'
      expect(page).to have_content 'Invalid message url!'
    end # after edited from timeout to visits
  end # when message self-destruction by visits

  # -----------------------------------
  # time out
  # -----------------------------------
  context 'when message self-destruction by time out' do
    scenario 'when time is over' do
      message = create(:message, destruction: 'timeout')
      message.decrypt!

      # time is not over
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      # time is over
      message.update_attribute(
        :deadline_at, message.deadline_at -
        message.destruction_value.hour -
        1.minute
      )
      expect { visit "/message/#{message.secure_id}" }
        .to change(Message, :count).by(-1)
      expect(current_path).to eq '/'
      expect(page).to have_content 'Invalid message url!'
    end # when time is over

    scenario 'after edited from \'visits\' to \'timeout\'' do
      message = create(:message)
      message.decrypt!

      # visit 1
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      message.update_attributes(destruction: 'timeout', destruction_value: 3)
      message.decrypt!

      # visit 2, time is not over
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      message.update_attribute(:deadline_at, message.deadline_at - 2.hour)
      message.decrypt!

      # visit 3, time is not over
      expect { visit "/message/#{message.secure_id}" }
        .to change { Message.find(message.id).visits }.by(1)
        .and change(Message, :count).by(0)
      expect(page).to have_content message.title
      expect(page).to have_content message.body
      expect(page).not_to have_link 'Edit'
      expect(page).not_to have_button 'Delete'

      message.update_attribute(:deadline_at, message.deadline_at - 1.hour - 1.minute)
      message.decrypt!

      # visit 4, time is over
      expect { visit "/message/#{message.secure_id}" }
        .to change(Message, :count).by(-1)
      expect(current_path).to eq '/'
      expect(page).to have_content 'Invalid message url!'
    end # after edited visits -> timeout
  end # when message self-destruction by time out
end # Guest
