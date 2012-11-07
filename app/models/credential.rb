class Credential < ActiveRecord::Base
  validate :email, presence: true, uniqueness: true
  belongs_to :user
end
