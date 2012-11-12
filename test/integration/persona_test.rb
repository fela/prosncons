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
    #Capybara.current_session.driver.quit
    sleep(0.2)
    page.execute_script("navigator.id.logout()")
    assert page.has_content?('you are not logged in')
    click_link('you are not logged in')
    click_link('Log In')
    main_window, persona_popup = page.driver.browser.window_handles
    within_window(persona_popup) do
      click_link('thisIsNotMe')
      sleep(1)
      page.execute_script "window.close();"
    end
    page.driver.browser.switch_to.window(main_window)
  end


  test 'normal login' do
    visit(root_path)
    within('.navbar') do
      assert page.has_content?('you are not logged in')
    end
    email = users(:alice).primary_email
    login(email)
    within('.navbar') do
      assert page.has_content?('logged in')
      assert page.has_content?(email)
    end
  end


  test 'unused login and then cancel' do
    visit(root_path)
    email = 'neverbeforeusedemail212324@mockmyid.com'
    login(email)
    within('h2') do
      assert page.has_content?('New Profile')
    end
    visit(root_path)
    sleep(1)
    within('.navbar') do
      assert page.has_content?('you are not logged in')
    end
  end

  test 'unused login and create new profile' do
    user_count = User.count
    cred_count = Credential.count
    visit(root_path)
    email = 'neverbeforeusedemail212324@mockmyid.com'
    login(email)
    within('h2') do
      assert page.has_content?('New Profile')
    end
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

  test 'unused login and merge to existing account' do begin
    user_count = User.count
    cred_count = Credential.count
    visit(root_path)
    email = 'neverbeforeusedemail212324@mockmyid.com'
    login(email)
    within('h2') do
      assert page.has_content?('New Profile')
    end
    click_link('Add email to existing account')

    email2 = users(:alice).primary_email
    Capybara.default_wait_time = 20 # persona login could take some time
    sleep(0.2)
    main_window, persona_popup = page.driver.browser.window_handles
    within_window(persona_popup) do
      click_link('Add another email address')
      fill_in('email', :with => email2)
      click_button('add')
    end
    page.driver.browser.switch_to.window(main_window)
    within('.navbar') do
      sleep(8)
      assert page.has_content?(email2)
    end

    assert_equal root_path, current_path

    assert_equal user_count, User.count
    assert_equal cred_count+1, Credential.count
    assert !User.find_by_primary_email(email2)
    assert_equal email, User.find_by_email(email2).primary_email
    assert_equal 1, Credential.find_all_by_email(email).count
  ensure
    Capybara.default_wait_time = 5
  end end


  private


  def display_cookies
    #puts '=== begin of cookies ==='
    #puts page.driver.browser.manage.all_cookies.map(&:inspect).join("\n")
    #"#{puts '===  end of cookies  ==='
    #puts
  end
end