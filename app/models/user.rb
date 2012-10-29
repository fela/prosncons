class User < ActiveRecord::Base
  NAME_FORMAT = /\A\w\w\w\w+\z/
  NAME_MSG = 'Username can contain only letters, numbers and underscore'
  attr_accessible :name, :password, :password_confirmation
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
  validates_format_of :username, with: NAME_FORMAT, message: NAME_MSG



  #include PasswordHash
  def encrypt_password
    if password.present?
      self.password_hash = PasswordHash.create_hash(password)
    end
  end

  def self.authenticate(username, pw)
    user = find_by_username(username)
    if user && PasswordHash.valid_password?(pw, user.password_hash)
      user
    else
      nil
    end
  end
end
