class Vote < ActiveRecord::Base
  belongs_to :votable, polymorphic: true
  belongs_to :user
  has_many :indirect_votes, dependent: :nullify

  alias_attribute :author, :user
end