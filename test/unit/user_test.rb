require 'test_helper'

class UserTest < ActiveSupport::TestCase

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

  test 'secondary_emails' do
    u = users(:alice)
    new_email = 'addedemail@email.com'
    u.add_email new_email
    expected = ['alice2@mockmyid.com', new_email].sort
    assert_equal expected, u.secondary_emails.sort
  end

  test 'avatar_url' do
    u = users(:alice)
    url = u.avatar_url(30)
    puts u.primary_email
    exp = 'http://gravatar.com/avatar/a13ff4259f302b291465bae4a48087d4.png?s=30'
    assert_equal exp, url
  end

  test 'case insensitive emails' do
    u = User.new
    email = credentials(:unused).email
    email2 = email.upcase
    u.primary_email = email2
    assert_equal email, u.primary_email
  end

  test 'validation: no credential for primary_email' do
    u = User.new
    u.primary_email = 'an_unique_email@abc.com'
    assert !u.valid?
  end

  test 'validation: no credential after changing primary_email' do
    u = users(:alice)
    u.primary_email = 'an_unique_email@abc.com'
    assert !u.valid?
  end

  test 'logged_in updates the creation time if user is existing' do
    time = 1.day.from_now
    u = nil
    Timecop.freeze(time) do
      u = User.logged_in(users(:alice).primary_email)
    end
    # for some reason the two times are not ==, but this way it works
    assert_equal 0.0, time - u.updated_at
  end

  test 'logged_in returns the correct existing user' do
    u = User.logged_in(users(:alice).primary_email)
    assert_equal users(:alice), u
  end

  test 'create_account creates a new account and credential' do
    user_count = User.count
    cred_count = Credential.count
    email = 'new_unused_email@email.com'
    u = User.create_account(email)
    assert_equal u, User.find_by_primary_email(email)
    assert_equal email, u.primary_email
    assert_equal user_count+1, User.count
    assert_equal cred_count+1, Credential.count
    assert_equal 1, Credential.find_all_by_email(email).count
  end

  test 'find_by_email returns nil if the email is not in Credentials' do
    assert_nil User.find_by_email('longandunexisitingemail342@blahh.com')
  end

  test 'find_by_email returns nil if an unused credential is passed' do
    assert_nil User.find_by_email(credentials(:unused).email)
  end

  test 'find_by_email should work for existing primary email' do
    assert_equal users(:alice), User.find_by_email(users(:alice).primary_email)
  end

  test 'find_by_email should work for other correct email' do
    assert_equal users(:alice), User.find_by_email(credentials(:alice2).email)
  end

  test 'add_email adds a credential' do
    user_count = User.count
    cred_count = Credential.count
    email = 'new_unused_email@email.com'
    u = users(:alice)
    u.add_email(email)
    assert_equal user_count, User.count
    assert_equal cred_count+1, Credential.count
    assert_equal 1, Credential.find_all_by_email(email).count
    assert u.credentials.any?{|c| c.email == email}
  end

  test 'urls serialization' do
    u = users(:alice)
    first = 'http://www.google.com'
    second = 'http://www.microsoft.com'
    u.urls = [first, second]
    u.save!
    u = User.find(u.id)
    assert_equal first, u.urls.first
    assert_equal second, u.urls.second
  end


end
