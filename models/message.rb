class Message < ActiveRecord::Base
  validates :title, presence: true, length: { minimum: 5 }
  validates :body, presence: true

  before_create :fix_deadline!
  before_create :encrypt!
  before_update :fix_deadline!
  before_update :encrypt!

  # ---------------------------------
  # removal of overdue messages
  # ---------------------------------
  def self.clear_timeout!
    where(['destruction = ? AND deadline_at <= ?', 'timeout', Time.now]).delete_all
  end

  # ---------------------------------
  # encrypted using AES algorithm
  # ---------------------------------

  def encrypt!
    return false if self.title.empty? || self.body.empty?
    self.secure_id ||= SecureRandom.urlsafe_base64(6)
    self.key       ||= AES.key
    self.title = AES.encrypt(self.title, self.key)
    self.body  = AES.encrypt(self.body, self.key)
    self
  end

  def decrypt!
    return false if self.title.empty? || self.body.empty? || self.key.blank?
    self.title = AES.decrypt(self.title, self.key)
    self.body  = AES.decrypt(self.body, self.key)
    self
  end

  # ---------------------------------
  # self-destruction
  # ---------------------------------
  def delete_by_timeout!
    return false if self.destruction != 'timeout'
    if Time.now > (self.deadline_at || 0)
      self.destroy
      self.destroyed?
    else
      false
    end
  end

  def delete_by_visits!(session_id)
    return false if self.destruction != 'visits' ||
      session_id == self.owner_session_id

    if self.visits > self.destruction_value
      self.destroy
      self.destroyed?
    else
      false
    end
  end

  def owner?(session_id)
    session_id == self.owner_session_id
  end

  private

    def fix_deadline!
      return if self.destruction != 'timeout'
      return unless self.deadline_at.nil?
      self.deadline_at = self.created_at + self.destruction_value.hour
    end
end # Message
