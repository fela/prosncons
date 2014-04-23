class Argument < ActiveRecord::Base
  # parameters for the prior beta distribution (used for bayesian average score)
  BETA_PARAMETERS = {a: 2, b: 1}


  has_paper_trail :on => [:update, :destroy]
  attr_accessible :summary, :description, :option
  validates_presence_of :summary, :description, :option, :page
  belongs_to :page
  has_many :votes, as: :votable
  has_many :indirect_votes
  belongs_to :user

  alias_attribute :author, :user

  def option_string
    page.options[option]
  end

  # returns all versions including the user that made it and the
  def version_history
    res = []
    event = 'create'
    author = user
    versions.each do |version|
      # some old entries still include create actions
      # TODO remove next line
      next if version.event == 'create'
      res << {
          obj: version.reify,
          event: event,
          author: author
      }
      event = version.event
      author = User.find_by_id(version.whodunnit.to_i)
    end
    res << {
        obj: self,
        event: event,
        author: author
    }
  end

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

  def views
    author_views = indirect_votes.group_by {|x| x.vote.author}.values
    author_views.map(&author_view).inject{|x, y| x+y}
  end

  # probability a certain author viewed it given the indirect votes
  def view_probability(indirect_votes)
    max = 0
    indirect_votes.each do |iv|
      if iv.direct_vote?
        return 0
      else
        max = [iv.view_probability, max].max
      end
    end
    max
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
