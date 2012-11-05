class User < ActiveRecord::Base
  def self.logged_in(email)
    user = find_by_email(email)
    if user
      user.touch
    else
      u = User.new()
      u.email = email
      u.save
    end
  end
end
