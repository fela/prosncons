class Credential < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true
  belongs_to :user
end
