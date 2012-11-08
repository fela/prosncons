class User < ActiveRecord::Base
  validates :primary_email, presence: true, uniqueness: true
  validate :has_primary_credential

  serialize :urls # array of strings
  has_many :credentials

  def display_name
    name or "user#{id}"
  end

  def primary_email=(email)
    write_attribute(:primary_email, email.downcase)
  end

  def self.logged_in(email)
    user = find_by_email(email)
    if user
      user.touch
      user.save!
    else
      cred = Credential.create!(email: email)
      user = User.create! do |u|
        u.primary_email = email
        u.credentials << cred
      end
    end
    user
  end

  def self.find_by_email(email)
    c = Credential.find_by_email(email)
    c && c.user
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