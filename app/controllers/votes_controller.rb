class VotesController < ApplicationController
  def create
    argument = Argument.find(params[:argument_id])
    vote = case params[:vote]
      when 'up' then 1
      when 'down' then -1
      else 0
    end

    if vote != 0
      v = Vote.new
      v.vote = vote
      v.votable = argument
      v.save
    end
    s = "%.1f" % (argument.score * 10)
    render text: s
  end
end