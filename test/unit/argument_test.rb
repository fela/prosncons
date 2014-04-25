require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase
  test 'paper trail' do
    argument = arguments(:page1arg1)
    argument.summary = 'First Summary'
    argument.description = 'First description'
    argument.save
    argument.summary = 'Second Summary'
    argument.description = 'Second description'
    argument.save
    argument = Argument.find(argument.id)
    last = argument.versions.last.reify
    assert_equal last.summary, 'First Summary'
    assert_equal last.description, 'First description'
    argument = Argument.find(argument.id)
    assert_equal argument.summary, 'Second Summary'
    assert_equal argument.description, 'Second description'
    last.save
    argument = Argument.find(argument.id)
    assert_equal argument.summary, 'First Summary'
    assert_equal argument.description, 'First description'
  end

  test 'option_string' do
    arg1, arg4 = arguments(:page1arg1),arguments(:page1arg4)
    assert_equal 'pros', arg1.option_string
    assert_equal 'cons', arg4.option_string
    page = pages(:page1)
    page.update_attributes(option1: 'a', option2: 'b')
    page.save!
    # clear cache
    arg1.page(true)
    arg4.page(true)
    assert_equal 'a', arg1.option_string
    assert_equal 'b', arg4.option_string
  end


  def indirect_vote_mock(direct_vote: false, view_prob: 0.5,
      removed_vote: false, author: 0)
    iv = IndirectVote.new
    iv.stubs(:direct_vote?).returns(direct_vote)
    iv.stubs(:view_probability).returns(view_prob)
    iv.stubs(:removed_vote?).returns(removed_vote)
    iv.stubs(:author).returns(author)
    iv
  end

  def _test_view_probability(expected, view_probs)
    # transform view_probs in indirect_votes
    indirect_votes = view_probs.map do |v|
      if v == :direct_vote
        indirect_vote_mock(direct_vote: true, view_prob: 0.9)
      elsif v == :removed_vote
        indirect_vote_mock(
            direct_vote: true,
            view_prob: 0.9,
            removed_vote: true
        )
      else
        indirect_vote_mock(view_prob: v)
      end
    end
    arg = arguments(:page1arg1)
    assert_equal expected, arg.view_probability(indirect_votes)
  end

  test 'view_probability' do
    _test_view_probability 0, [0.1, 0.2, 0.3, 0.4, :direct_vote, 0.5]
    _test_view_probability 0.9, [0.1, 0.2, 0.3, 0.4, :removed_vote, 0.5]
    _test_view_probability 0, [0.1, :removed_vote, 0.3, 0.4, :direct_vote, 0.5]
    _test_view_probability 0.6, [0.1, 0.2, 0.3, 0.6, 0.5]
    _test_view_probability 0.8, [0.8, 0.2, 0.3, 0.6, 0.5]
    _test_view_probability 0.8, [0.1, 0.2, 0.3, 0.6, 0.8]
    _test_view_probability 0, []
    _test_view_probability 0.12, [0.12]
  end

  test 'views_estimate no indirect votes' do
    arg = arguments(:page1arg1)
    assert_equal 0, arg.views_estimate
  end

  test 'views_estimate single vote' do
    arg1 = arguments(:page1arg3)
    arg2 = arguments(:page1arg4)
    arg3 = arguments(:page1arg5)
    arg_other_1 = arguments(:page1arg1)
    arg_other_2 = arguments(:page1arg2)

    arg1.vote(user: users(:alice), vote_type: :up)
    [arg1, arg2, arg3, arg_other_1, arg_other_2].each {|a| a.reload}
    assert_equal 0, arg1.views_estimate
    assert_in_epsilon 0.7**2, arg2.views_estimate
    assert_in_epsilon 0.7**3, arg3.views_estimate
    assert_in_epsilon 0.6*0.8, arg_other_1.views_estimate
    assert_in_epsilon 0.6*0.7*0.7, arg_other_2.views_estimate

    arg1.vote(user: users(:alice), vote_type: :down)
    [arg1, arg2, arg3, arg_other_1, arg_other_2].each {|a| a.reload}
    assert_equal 0, arg1.views_estimate
    assert_in_epsilon 0.7**2, arg2.views_estimate
    assert_in_epsilon 0.7**3, arg3.views_estimate
    assert_in_epsilon 0.6*0.8, arg_other_1.views_estimate
    assert_in_epsilon 0.6*0.7*0.7, arg_other_2.views_estimate

    arg1.vote(user: users(:alice), vote_type: :undo)
    [arg1, arg2, arg3, arg_other_1, arg_other_2].each {|a| a.reload}
    assert_equal 0.9, arg1.views_estimate
    assert_in_epsilon 0.7**2, arg2.views_estimate
    assert_in_epsilon 0.7**3, arg3.views_estimate
    assert_in_epsilon 0.6*0.8, arg_other_1.views_estimate
    assert_in_epsilon 0.6*0.7*0.7, arg_other_2.views_estimate

    arg1.vote(user: users(:alice), vote_type: :down)
    arg1.vote(user: users(:bob), vote_type: :down)
    [arg1, arg2, arg3, arg_other_1, arg_other_2].each {|a| a.reload}
    assert_equal 0, arg1.views_estimate
    assert_in_epsilon 0.7**2 + 0.8, arg2.views_estimate
    assert_in_epsilon 0.7**3 + 0.8, arg3.views_estimate
    assert_in_epsilon 0.6*0.8 + 0.6*0.8, arg_other_1.views_estimate
    assert_in_epsilon 0.6*0.7*0.7 + 0.6*0.8, arg_other_2.views_estimate
  end
end
