require 'test_helper'

class PersonaTest < ActionDispatch::IntegrationTest
  def self.startup
    Capybara.default_driver = :selenium
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
    assert page.has_content?('New Profile')
    visit(root_path)
    assert page.has_content?('you are not logged in')

    page.execute_script("navigator.id.logout()")
    assert page.has_content?('you are not logged in')
  end


  private
  def login(email=users(:alice).primary_email)
    Capybara.default_wait_time = 20 # persona login could take some time
    page.execute_script("navigator.id.request()")
    #page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    main_window, persona_popup = page.driver.browser.window_handles
    within_window(persona_popup) do
      fill_in('email', :with => email)
      click_button('next')
    end
    page.driver.browser.switch_to.window(main_window)
    within('.navbar') do
      sleep(6)
      # wait till the login completed: this could take some time
      page.has_content?(email)
    end
  ensure
    Capybara.default_wait_time = 5
  end

  def display_cookies
    #puts '=== begin of cookies ==='
    #puts page.driver.browser.manage.all_cookies.map(&:inspect).join("\n")
    #"#{puts '===  end of cookies  ==='
    #puts
  end
end