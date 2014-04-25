class IndirectVote < ActiveRecord::Base
  belongs_to :vote
  belongs_to :argument
  belongs_to :voted_for_argument, class_name: 'Argument'
  belongs_to :author, class_name: 'User'

  before_create do
    self.voted_for_argument = vote.votable if voted_for_argument.blank?
    self.author = vote.user if author.blank?
    self.same_option = voted_for_argument.option == argument.option
    true
  end

  def direct_vote?
    voted_for_argument == argument
  end

  def removed_vote?
    vote.nil?
  end

  def view_probability
    return 0.9 if direct_vote?
    if position <= voted_for_position
      res = 0.8
    else
      res = 0.7 * 0.7**(position - voted_for_position)
    end
    res *= 0.6 unless same_option
    res
  end
end
