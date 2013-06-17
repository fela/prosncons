class Credential < ActiveRecord::Base
  attr_accessible :email

  validates :email, presence: true, uniqueness: true
  belongs_to :user

  def email=(new_email)
    write_attribute(:email, new_email.downcase)
  end

  def primary?
    user.primary_email == email
  end
end
