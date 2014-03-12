require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase
  test "paper trail" do
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
end
