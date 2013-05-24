class Argument < ActiveRecord::Base
  # parameters for the prior beta distribution (used for bayesian average score)
  BETA_PARAMETERS = {a: 2, b:1}


  attr_accessible :summary, :description, :option
  validates_presence_of :summary, :description, :option, :page
  belongs_to :page
  has_many :votes, as: :votable
  belongs_to :user

  alias :author :user

  def score
    up = n_upvotes
    tot = n_upvotes + n_downvotes
    a = beta_parameters[:a]
    b = beta_parameters[:b]
    (up + a).to_f / (tot + a + b)
  end

  def n_upvotes
    votes.select{|v|v.vote > 0}.size
  end

  def n_downvotes
    votes.select{|v| v.vote < 0}.size
  end

  def beta_parameters
    BETA_PARAMETERS
  end
  # validate :my_method
  #def expiration_date_cannot_be_in_the_past
  #  if !expiration_date.blank? and expiration_date < Date.today
  #    errors.add(:expiration_date, "can't be in the past")
  #  end
  #end
end
