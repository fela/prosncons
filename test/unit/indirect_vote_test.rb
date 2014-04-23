require 'test_helper'

class IndirectVoteTest < ActiveSupport::TestCase
  def create_indirect_vote(argument: :page1arg2, position: 2, voted_for_position: 1)
    arg = arguments(argument)
    voted_for_argument = votes(:one).votable
    same_option = arg.option == voted_for_argument.option
    IndirectVote.create! do |iv|
      iv.vote = votes(:one)
      iv.argument = arg
      iv.position = position
      iv.voted_for_position = voted_for_position
      iv.same_option = same_option
    end
  end

  test 'voted_for_argument' do
    indirect_vote = create_indirect_vote
    assert_equal arguments(:page1arg1), indirect_vote.voted_for_argument
    assert_equal 'granularity', indirect_vote.voted_for_argument.summary
  end

  test 'direct_vote? true' do
    indirect_vote = create_indirect_vote(argument: :page1arg1, position: 1)
    assert indirect_vote.direct_vote?
  end

  test 'direct_vote? false' do
    indirect_vote = create_indirect_vote
    refute indirect_vote.direct_vote?
  end

  test 'view probability for direct vote should be nil' do
    indirect_vote = create_indirect_vote(argument: :page1arg1, position: 1)
    assert_nil indirect_vote.view_probability
  end

  test 'view probability for same option same position' do
    indirect_vote = create_indirect_vote(argument: :page1arg1, position: 1)
    assert_nil indirect_vote.view_probability
  end

  test 'view probability different option same position' do
    indirect_vote = create_indirect_vote(argument: :page1arg4, position: 1)
    assert_in_epsilon 0.6*0.8, indirect_vote.view_probability
  end

  test 'view probability different option after' do
    indirect_vote = create_indirect_vote(argument: :page1arg4, position: 2)
    assert_in_epsilon 0.6*0.7*0.7, indirect_vote.view_probability
  end

  test 'view probability different option before' do
    indirect_vote = create_indirect_vote(
        argument: :page1arg4,
        position: 2,
        voted_for_position: 3
    )
    assert_in_epsilon 0.6*0.8, indirect_vote.view_probability
  end

  test 'view probability different option much before' do
    indirect_vote = create_indirect_vote(
        argument: :page1arg4,
        position: 2,
        voted_for_position: 10
    )
    assert_in_epsilon 0.6*0.8, indirect_vote.view_probability
  end

  test 'view probability same option before' do
    indirect_vote = create_indirect_vote(
        position: 3,
        voted_for_position: 4
    )
    assert_in_epsilon 0.8, indirect_vote.view_probability
  end

  test 'view probability same option much before' do
    indirect_vote = create_indirect_vote(
        position: 1,
        voted_for_position: 20
    )
    assert_in_epsilon 0.8, indirect_vote.view_probability
  end

  test 'view probability same option just after' do
    indirect_vote = create_indirect_vote(
        position: 3,
        voted_for_position: 2
    )
    assert_in_epsilon 0.7*0.7, indirect_vote.view_probability
  end

  test 'view probability same option 2 after' do
    indirect_vote = create_indirect_vote(
        position: 13,
        voted_for_position: 11
    )
    assert_in_epsilon 0.7*0.7*0.7, indirect_vote.view_probability
  end
end