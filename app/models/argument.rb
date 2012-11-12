class Argument < ActiveRecord::Base
  attr_accessible :summary, :description, :option
  validates_presence_of :summary, :description, :option, :page
  belongs_to :page
  has_many :votes, as: :votable
  belongs_to :author, class_name: User

  def score
    votes.inject(0) {|sum, v| sum + v.vote}
  end
  # validate :my_method
  #def expiration_date_cannot_be_in_the_past
  #  if !expiration_date.blank? and expiration_date < Date.today
  #    errors.add(:expiration_date, "can't be in the past")
  #  end
  #end
end
