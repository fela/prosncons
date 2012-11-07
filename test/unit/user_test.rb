require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'can save with primary email' do
    u = User.new
    u.primary_email = credentials(:unused).email
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
    u = User.new
    u.primary_email = users(:alice).primary_email
    assert !u.valid?, "#{u.inspect} is valid, it shouldn't be"
    assert !u.save, "#{u.inspect} could be saved, it shouldn't have"
    msg = u.errors.messages[:primary_email].first
    assert_match /already been taken/, msg
  end

  test 'email has to be unique after modification' do
    email1 = credentials(:unused1).email
    email2 = credentials(:unused2).email
    u = User.new
    u.primary_email = email2
    u.save!
    u2 = User.new
    u2.primary_email = email1
    u2.save!

    u.primary_email = email1
    assert !u.valid?, "#{u.inspect} is valid, it shouldn't be"
    assert !u.save, "#{u.inspect} could be saved, it shouldn't have"
    msg = u.errors.messages[:primary_email].first
    assert_match /already been taken/, msg
  end

  test 'avatar_url' do
    u = users(:alice)
    url = u.avatar_url(30)
    exp = 'http://gravatar.com/avatar/c3fbd1a1111b724ab3f1aa2dc3229a36.png?s=30'
    assert_equal exp, url
  end

  test 'case insensitive emails' do
    u = User.new
    email = credentials(:unused).email
    email2 = email.upcase
    Credential.create do |c|
      c.email = email2
    end
    u.primary_email = email2
    assert_equal email, u.primary_email
  end
end
