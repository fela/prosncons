class Argument < ActiveRecord::Base
  # parameters for the prior beta distribution (used for bayesian average score)
  BETA_PARAMETERS = {a: 2, b: 1}


  has_paper_trail
  attr_accessible :summary, :description, :option
  validates_presence_of :summary, :description, :option, :page
  belongs_to :page
  has_many :votes, as: :votable
  belongs_to :user

  alias :author :user

  # creates a new vote
  # params are :user and :vote_type (:up or :down or :undo)
  # validation should be done in the controller \w cancan
  def vote(opts)
    user      = opts[:user]      or raise ArgumentError
    vote_type = opts[:vote_type] or raise ArgumentError
    if vote_type.to_sym == :undo
      undo_vote(user)
      return
    end
    vote_val = case vote_type.to_sym
                 when :up
                   1
                 when :down
                   -1
                 else
                   raise ArgumentError
               end
    # remove any possible vote in the other direction
    undo_vote(user)
    vote = Vote.new
    vote.user = user
    vote.vote = vote_val
    vote.save!

    votes << vote
    save!
  end

  def undo_vote(user)
    votes.where(user_id: user).destroy_all
  end

  def voting_status(user)
    return nil if user.nil?
    vote = votes.where(user_id: user).first
    return nil if vote.nil?
    vote.vote > 0 ? 'up-voted' : 'down-voted'
  end

  def score
    up = n_upvotes
    tot = n_upvotes + n_downvotes
    a = beta_parameters[:a]
    b = beta_parameters[:b]
    (up + a).to_f / (tot + a + b)
  end

private
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
