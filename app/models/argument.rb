class Argument < ActiveRecord::Base
  # parameters for the prior beta distribution (used for bayesian average score)
  BETA_PARAMETERS = {a: 2, b: 1}


  has_paper_trail :on => [:update, :destroy]
  attr_accessible :summary, :description, :option
  validates_presence_of :summary, :description, :option, :page
  validates :summary, length: {in: 6..64}

  belongs_to :page
  has_many :votes, as: :votable
  has_many :comments, as: :about
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
    # get arguments in their positions before the vote
    args1 = page.arguments1.to_a
    args2 = page.arguments2.to_a

    # remove any possible vote in the other direction
    undo_vote(user)
    vote = Vote.new
    vote.user = user
    vote.vote = vote_val
    vote.votable = self
    vote.save!

    votes << vote
    save!

    add_indirect_votes args1, args2, vote
  end

  def undo_vote(user)
    votes.where(user_id: user).destroy_all
  end

  def add_indirect_votes(args1, args2, vote)
    position = [args1, args2][option].index(self)
    [args1, args2].each_with_index do |args|
      args.each_with_index do |arg, index|
        iv = IndirectVote.new
        iv.argument = arg
        iv.vote = vote
        iv.position = index
        iv.voted_for_position = position
        unless iv.save
          puts iv.errors.full_messages
          raise iv.errors.full_messages.inspect
        end
      end
    end
  end

  def voting_status(user)
    return nil if user.nil?
    vote = votes.where(user_id: user).first
    return nil if vote.nil?
    vote.vote > 0 ? 'up-voted' : 'down-voted'
  end

  def score
    n_views = views_estimate
    up = n_upvotes + n_views * 0.5
    tot = n_upvotes + n_downvotes + n_views
    a = beta_parameters[:a]
    b = beta_parameters[:b]
    (up + a).to_f / (tot + a + b)
  end

  def views_estimate
    author_views = indirect_votes.group_by {|x| x.author}.values
    author_views.map{|iv| view_probability(iv)}.inject(0){|x, y| x + y}
  end

  # helper
  # probability a certain author viewed it given the indirect votes
  def view_probability(indirect_votes)
    max = 0
    indirect_votes.each do |iv|
      if iv.direct_vote? and not iv.removed_vote?
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
