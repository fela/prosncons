class IndirectVote < ActiveRecord::Base
  belongs_to :vote
  belongs_to :argument

  def voted_for_argument
    vote.votable
  end

  def author
    vote.author
  end

  def direct_vote?
    voted_for_argument == argument
  end

  def view_probability
    return nil if direct_vote?
    if position <= voted_for_position
      res = 0.8
    else
      res = 0.7 * 0.7**(position - voted_for_position)
    end
    res *= 0.6 unless same_option
    res
  end
end
