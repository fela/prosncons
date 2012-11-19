class User < ActiveRecord::Base
  attr_accessible :name
  validates :primary_email, presence: true, uniqueness: true
  validate :has_primary_credential

  serialize :urls # array of strings
  has_many :credentials
  has_many :pages

  def display_name
    name or "user#{id}"
  end

  def primary_email=(email)
    write_attribute(:primary_email, email.downcase)
  end

  def self.logged_in(email)
    user = find_by_email(email)
    user.touch
    user.save!
    user
  end

  def self.create_account(email)
    cred = Credential.create!(email: email)
    user = User.create! do |u|
      u.primary_email = email
      u.credentials << cred
    end
    user
  end

  def self.find_by_email(email)
    c = Credential.find_by_email(email.downcase)
    c && c.user
  end

  def add_email(email)
    Credential.create! do |c|
      c.email = email
      c.user = self
    end
  end

  def avatar_url(size=24)
    hash = Digest::MD5.hexdigest(primary_email.downcase)
    "http://gravatar.com/avatar/#{hash}.png?s=#{size}"
  end

  private
  def has_primary_credential
    if credentials.where(email: primary_email).empty?
      errors.add(:base, 'email must be in Credentials')
    end
  end
end