require 'test_helper'

class CredentialTest < ActiveSupport::TestCase
  test 'can create and save valid credential' do
    c = Credential.new
    c.email = 'really_unique_email@blablah.com'
    c.save!
    assert c.valid?
  end
  test 'unique email' do
    c = Credential.new
    c.email = credentials(:bob).email
    assert !c.valid?, "#{c.inspect} should not be valid"
  end
  test 'email presence' do
    c = Credential.new
    assert !c.valid?, "#{c.inspect} should not be valid"
  end
  test 'user' do
    assert true
  end
end