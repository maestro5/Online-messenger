class CreateMessages < ActiveRecord::Migration
  def self.up
   create_table :messages do |t|
     t.string :title
     t.text :body
     t.string :destruction, default: 'visits'
     t.integer :destruction_value, default: 1
     t.integer :visits, default: 0
     t.string :owner_session_id
     t.string :secure_id
     t.string :key
     t.datetime :deadline_at

     t.timestamps
   end

   add_index :messages, :secure_id, unique: true
 end

 def self.down
   drop_table :messages
 end
end
