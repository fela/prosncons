require 'test_helper'

class PersonaTest < ActionDispatch::IntegrationTest
  def self.startup
    Capybara.default_driver = :selenium
    Capybara.default_wait_time = 5
    # problem with other drivers:
    # poltergeist doesn't provide proper multi-window
    # webkit doesn't allow the request to persona
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(1024, 768)
  end

  teardown do
    sleep(0.2) # no clue why it does not work without this :(
    page.execute_script("navigator.id.logout()")
    assert page.has_content?('you are not logged in')
  end

  # meta test
  test 'login test helper' do
    email1 = users(:alice).primary_email
    email2 = users(:bob).primary_email
    # normal login
    visit(root_path)
    login(email1)
    # add new login
    login(email2)
    # use existing login
    login(email1)
  end

  test 'normal login' do
    visit(root_path)
    within('.navbar') do
      assert page.has_content?('you are not logged in')
    end
    email = users(:alice).primary_email
    login(email)
    within('.navbar') do
      assert page.has_content?(email)
      assert page.has_content?('logged in')
    end
  end


  test 'unused login and then cancel' do
    visit(root_path)
    email = 'neverbeforeusedemail212324@mockmyid.com'
    login(email, i_will_check: true)
    check_new_profile
    visit(root_path)
    within('.navbar') do
      assert page.has_content?('you are not logged in')
    end
  end

  test 'unused login and create new profile' do
    user_count = User.count
    cred_count = Credential.count
    visit(root_path)
    email = 'neverbeforeusedemail212324@mockmyid.com'
    login(email, i_will_check: true)
    check_new_profile
    click_link('Create new account')
    assert_equal root_path, current_path
    within('.navbar') do
      assert page.has_content?(email)
    end

    assert_equal user_count+1, User.count
    assert_equal cred_count+1, Credential.count
    assert User.find_by_primary_email(email)
    assert_equal 1, Credential.find_all_by_email(email).count
  end

  test 'unused login and merge to existing account' do
    user_count = User.count
    cred_count = Credential.count
    visit(root_path)
    email = 'neverbeforeusedemail212324@mockmyid.com'
    login(email, i_will_check: true)
    check_new_profile
    click_on('Add email to existing account')

    email2 = users(:alice).primary_email

    login(email2)

    assert_equal root_path, current_path

    assert_equal user_count, User.count
    assert_equal cred_count+1, Credential.count
    assert !User.find_by_primary_email(email)
    assert_equal email2, User.find_by_email(email).primary_email
    assert_equal 1, Credential.find_all_by_email(email).count
  end


  private
  def check_new_profile
    using_wait_time(20) do
      within('h2') do
        assert page.has_content?('New Profile')
      end
    end
  end

  def display_cookies
    #puts '=== begin of cookies ==='
    #puts page.driver.browser.manage.all_cookies.map(&:inspect).join("\n")
    #"#{puts '===  end of cookies  ==='
    #puts
  end
end