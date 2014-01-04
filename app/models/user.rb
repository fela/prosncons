class User < ActiveRecord::Base
  attr_accessible :name
  validates :primary_email, presence: true, uniqueness: true
  validate :has_primary_credential

  serialize :urls # array of strings
  has_many :credentials
  has_many :pages
  has_many :votes
  has_many :arguments

  def display_name
    name or "user#{id}"
  end

  def primary_email=(email)
    write_attribute(:primary_email, email.downcase)
  end

  def secondary_emails
    # TODO use where not after RAILS4 conversion
    all_emails = credentials.map {|c| c.email}
    all_emails - [primary_email]
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

  # does not add the email and returns false if the email had an account has
  # already been used
  # TODO: write tests
  def add_email(email)
    email = email.downcase
    cred = Credential.find_by_email(email)
    if cred
      return false if cred.user.used?
      cred.user.destroy
      cred.destroy
    end
    Credential.create! do |c|
      c.email = email
      c.user = self
    end
    true
  end

  # TODO: write tests
  def used?
    !votes.empty? || !pages.empty? || !arguments.empty?
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