require 'passwordhash'

class User < ActiveRecord::Base
  NAME_FORMAT = /\A\w\w\w\w+\z/
  NAME_MSG = 'Username can contain only letters, numbers and underscore'
  attr_accessible :name, :password, :password_confirmation
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
  validates_format_of :name, with: NAME_FORMAT, message: NAME_MSG

  attr_accessor :password
  before_save :encrypt_password

  def encrypt_password
    if password.present?
      self.password_hash = PasswordHash.create_hash(password)
    end
  end

  def self.authenticate(username, pw)
    user = find_by_name(username)
    if user && PasswordHash.valid_password?(pw, user.password_hash)
      user
    else
      nil
    end
  end
end
