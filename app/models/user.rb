require 'set'
require 'digest'

class User < ActiveRecord::Base
  SALT = ':803e380b0a804bc9f0b4c97c30c17b1e0d255.7cf3384755c66aea79c2c82264b4c'
  # salted hashes of emails of beta testers
  BETA_TESTERS = %w(
    3j3KI990i+7C1GGCZBDwxPC8tVFwO+WxUZWQ1t9hm3A=
    ooktG4O/64NJJigUUvAB7K4eWpHbqocVYnaE2zl/38k=
    PtM9IZjv5Xh1QKg9ITK15I7WXIZltlT4C75CFDWHTGs=
    RWAd4rLm4x6eUQk7nQDnIvClBwLqRgnaTLJSuSmSuSU=
    J0JTW3G3XJWG6jCnRxoxBCMtiUOVmXh2+sBV/gJGD+I=
    LlqMwOjhjUoosvs5HEU4DUGdF7hVHVzn3lRVB2SQzTg=
    QVgtJAL3S0QrNvjvhMr+fcjCCxUNeoEtKpWjNIeo09Q=
    DtPJ0IaEjdsK5YgoSXfux7EF4EjghetyW1FAJ7t0lrE=
    /CpREHJGlW05RBJOkbdROLV9R/PPYVxo96sRaYEot2o=
  ).to_set

  attr_accessible :name
  validates :primary_email, presence: true, uniqueness: true
  validate :has_primary_credential

  serialize :urls # array of strings
  has_many :credentials
  has_many :pages
  has_many :votes
  has_many :arguments
  has_many :received_votes, through: :arguments, source: :votes

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

  def reputation(cached: true)
    # TODO: denormalize the reputation
    # the nil in the where is redundant but added for clarity
    if !@reputation || !cached
      @reputation = received_votes.where('vote > 0') \
                                  .where.not(user: [self, nil]).count
    end
    @reputation
  end

  def self.logged_in(email)
    user = find_by_email(email)
    user.touch
    user.save!
    user
  end

  def self.create_account(email)
    cred = Credential.create!(email: email)
    user = User.new
    user.primary_email = email
    user.credentials << cred
    # would not work because the credentials have not yet been updated
    user.save(validate: false)
    # now it can validate
    user.save!
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
    "http://gravatar.com/avatar/#{hash}.png?s=#{size}&default=identicon"
  end

  def beta_tester?
    hash = Digest::SHA256.new.base64digest primary_email + SALT
    # TODO: remove ID
    BETA_TESTERS.include? hash or id == 902541637
  end

  private
  def has_primary_credential
    if credentials.where(email: primary_email).empty?
      errors.add(:base, "email #{primary_email.inspect} must be in Credentials")
    end
  end
end