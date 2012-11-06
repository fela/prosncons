class User < ActiveRecord::Base
  def self.logged_in(email)
    user = find_by_email(email)
    if user
      user.touch
    else
      user = User.new()
      user.email = email
      user.save
    end
    user
  end

  def display_name
    name or "user#{id}"
  end

  def avatar_url(size=24)
    id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{id}.png?s=#{size}"
  end
end
