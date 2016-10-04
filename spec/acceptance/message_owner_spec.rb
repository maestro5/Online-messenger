require_relative '../acceptance_helper'

feature 'Guest', %q{
  As a guest
  I want to be able to create, edit and 
  delete a text self-destructing message
} do

  # -----------------------------------
  # create
  # -----------------------------------
  context 'when guest creates a message' do
    before { visit '/' }
    before { click_on 'Create Message' }

    scenario 'when empty title' do
      click_on 'Submit'
      expect(page).to have_content 'Title can\'t be blank'
    end # when empty title

    scenario 'when short title' do
      fill_in 'message[title]', with: 'text'
      click_on 'Submit'
      expect(page).to have_content 'Title is too short (minimum is 5 characters)'
    end # when short title

    scenario 'when empty body' do
      fill_in 'message[title]', with: 'Test title'
      click_on 'Submit'
      expect(page).to have_content 'Body can\'t be blank'
    end # when empty body

    scenario 'when visits destruction option' do
      fill_in 'message[title]', with: 'Test message'
      fill_in 'message[body]', with: 'Visits destruction option'
      fill_in 'destruction[visits]', with: 2
      fill_in 'destruction[timeout]', with: 3
      choose('visits')

      expect { click_on 'Submit' }.to change(Message, :count).by(1)

      # db
      new_message = Message.last
      expect(new_message.title).not_to eq 'Test message'
      expect(new_message.body).not_to eq 'Visits destruction option'
      expect(new_message.destruction).to eq 'visits'
      expect(new_message.destruction_value).to eq 2
      expect(new_message.visits).to eq 0
      expect(new_message.owner_session_id).not_to be_nil
      expect(new_message.secure_id).not_to be_nil
      expect(new_message.key).not_to be_nil
      expect(new_message.deadline_at).to be_nil

      # page
      expect(page).to have_content 'Message created'
      expect(page).to have_content 'Test message'
      expect(page).to have_content 'Visits destruction option'
      expect(page).to have_content 'Link for your message:'
      expect(find_field('message-url').value).to eq current_url

      # owner has actions
      expect(page).to have_link 'Edit'
      expect(page).to have_button 'Delete'
    end # create a message with visits destruction option

    scenario 'when timeout destruction option' do
      fill_in 'message[title]', with: 'Test message'
      fill_in 'message[body]', with: 'Timeout destruction option'
      fill_in 'destruction[visits]', with: 7
      fill_in 'destruction[timeout]', with: 3
      choose('hours')

      expect { click_on 'Submit' }.to change(Message, :count).by(1)

      # db
      new_message = Message.last
      expect(new_message.title).not_to eq 'Test message'
      expect(new_message.body).not_to eq 'Timeout destruction option'
      expect(new_message.destruction).to eq 'timeout'
      expect(new_message.destruction_value).to eq 3
      expect(new_message.visits).to eq 0
      expect(new_message.owner_session_id).not_to be_nil
      expect(new_message.secure_id).not_to be_nil
      expect(new_message.key).not_to be_nil
      expect(new_message.deadline_at).to eq new_message.created_at +
        new_message.destruction_value.hour

      # page
      expect(page).to have_content 'Message created'
      expect(page).to have_content 'Test message'
      expect(page).to have_content 'Timeout destruction option'
      expect(page).to have_content 'Link for your message:'
      expect(find_field('message-url').value).to eq current_url

      # owner has actions
      expect(page).to have_link 'Edit'
      expect(page).to have_button 'Delete'
    end # create a message with timeout destruction option
  end # when guest creates a message

  # -----------------------------------
  # edit
  # -----------------------------------
  context 'when guest edits a message' do
    before do
      visit '/message/create'
      fill_in 'message[title]', with: 'Test message'
      fill_in 'message[body]', with: 'Visits destruction option'
      fill_in 'destruction[visits]', with: 2
      choose('visits')
      click_on 'Submit'
    end # set owner session_id
    given!(:message) { Message.last }

    scenario 'when guest is not owner' do
      message_not_owner = create(:message)

      # action
      visit "/message/#{message_not_owner.secure_id}"
      expect(page).not_to have_link 'Edit'

      # route
      visit "/message/#{message_not_owner.secure_id}/edit"
      expect(current_path).to eq '/'
    end # when guest is not owner

    scenario 'when changing from \'visits\' to \'timeout\'' do
      visit "/message/#{message.secure_id}/edit"
      fill_in 'message[title]', with: 'Edited test message'
      fill_in 'message[body]', with: 'Timeout destruction option'
      fill_in 'destruction[visits]', with: 4
      fill_in 'destruction[timeout]', with: 5
      choose('hours')
      expect { click_on 'Submit' }.not_to change(Message, :count)

      # db
      prev_secure_id = message.secure_id
      message.reload
      expect(message.title).not_to eq 'Edited test message'
      expect(message.body).not_to eq 'Timeout destruction option'
      expect(message.destruction).to eq 'timeout'
      expect(message.destruction_value).to eq 5
      expect(message.secure_id).to eq prev_secure_id
      expect(message.key).not_to be_nil
      expect(message.deadline_at).to eq message.created_at +
        message.destruction_value.hour

      # page
      expect(page).to have_content 'Message edited!'
      expect(page).to have_content 'Edited test message'
      expect(page).to have_content 'Timeout destruction option'
      expect(find_field('message-url').value).to eq current_url

      # owner has actions
      expect(page).to have_link 'Edit'
      expect(page).to have_button 'Delete'
    end # visits -> timeout

    scenario 'when changing from \'timeout\' to the \'visits\'' do
      message.decrypt!
      message.update_attribute(:destruction, 'timeout')

      visit "/message/#{message.secure_id}/edit"
      fill_in 'message[title]', with: 'Edited test message'
      fill_in 'message[body]', with: 'Visits destruction option'
      fill_in 'destruction[visits]', with: 10
      fill_in 'destruction[timeout]', with: 4
      choose('visits')
      expect { click_on 'Submit' }.not_to change(Message, :count)
      
      # db
      prev_secure_id = message.secure_id
      message.reload
      expect(message.title).not_to eq 'Edited test message'
      expect(message.body).not_to eq 'Visits destruction option'
      expect(message.destruction).to eq 'visits'
      expect(message.destruction_value).to eq 10
      expect(message.secure_id).to eq prev_secure_id
      expect(message.key).not_to be_nil

      # page
      expect(page).to have_content 'Message edited!'
      expect(page).to have_content 'Edited test message'
      expect(page).to have_content 'Visits destruction option'
      expect(find_field('message-url').value).to eq current_url

      # owner has actions
      expect(page).to have_link 'Edit'
      expect(page).to have_button 'Delete'
    end # timeout -> visits
  end # when guest edits a message

  # -----------------------------------
  # delete
  # -----------------------------------
  context 'when guest deletes a message' do
    scenario 'when not owner' do
      message_not_owner = create(:message)

      # action
      visit "/message/#{message_not_owner.secure_id}"
      expect(page).not_to have_button 'Delete'

      # route
      expect { delete "/message/#{message_not_owner.secure_id}" }
        .not_to change(Message, :count)
    end # when not owner

    scenario 'when owner' do
      visit '/message/create'
      fill_in 'message[title]', with: 'Test message'
      fill_in 'message[body]', with: 'Visits destruction option'
      fill_in 'destruction[visits]', with: 2
      choose('visits')
      click_on 'Submit'

      message = Message.last.decrypt!
      expect { click_on 'Delete' }.to change(Message, :count).by(-1)
      expect(current_path).to eq '/'
      expect(page).to have_content "Message \"#{message.title}\" deleted!"
    end # when owner
  end # when guest deletes a message
end # Guest
