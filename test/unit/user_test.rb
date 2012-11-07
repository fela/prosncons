require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'can save with primary email' do
    u = User.new
    u.primary_email = 'test'
    assert u.valid?
    assert u.save
  end

  test 'cannot save without primary email' do
    u = User.new
    assert !u.valid?, "#{u.inspect} is valid, it shouldn't be"
    assert !u.save, "#{u.inspect} could be saved, it shouldn't have"
    msg = u.errors.messages[:primary_email].first
    assert_match /can't be blank/, msg
  end

  test 'email has to be unique' do
    email = 'uniqueness_test@email.com'
    u = User.new
    u.primary_email = email
    u.save
    u = User.new
    u.primary_email = email
    assert !u.valid?, "#{u.inspect} is valid, it shouldn't be"
    assert !u.save, "#{u.inspect} could be saved, it shouldn't have"
    msg = u.errors.messages[:primary_email].first
    assert_match /already been taken/, msg
  end

  test 'email has to be unique after modification' do
    email = 'uniquenesstest1@email.com'
    u = User.new
    u.primary_email = "other#{email}"
    u.save!
    u2 = User.new
    u2.primary_email = email
    u2.save!

    u.primary_email = email
    assert !u.valid?, "#{u.inspect} is valid, it shouldn't be"
    assert !u.save, "#{u.inspect} could be saved, it shouldn't have"
    msg = u.errors.messages[:primary_email].first
    assert_match /already been taken/, msg
  end

  test 'avatar_url' do
    u = User.new
    u.primary_email = 'tEst@emAil.com'
    u.save
    url = u.avatar_url(30)
    exp = 'http://gravatar.com/avatar/93942e96f5acd83e2e047ad8fe03114d.png?s=30'
    assert_equal exp, url
  end
end
