class Credential < ActiveRecord::Base
  attr_accessible :email

  validates :email, presence: true, uniqueness: true
  belongs_to :user
end
