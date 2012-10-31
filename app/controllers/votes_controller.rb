class VotesController < ApplicationController
  def create
    new_vote = '10'
    expires_now
    render text: new_vote
  end
end