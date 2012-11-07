class User < ActiveRecord::Base
  validates :primary_email, presence: true, uniqueness: true

  serialize :urls # array of strings
  has_many :credentials

  def display_name
    name or "user#{id}"
  end

  def self.logged_in(email)
    #user = find_by_email(email)
    #if user
    #  user.touch
    #else
    #  user = User.new()
    #  user.email = email
    #  user.save
    #end
    #user
  end

  def avatar_url(size=24)
    hash = Digest::MD5.hexdigest(primary_email.downcase)
    "http://gravatar.com/avatar/#{hash}.png?s=#{size}"
  end
end
