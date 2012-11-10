require 'test_helper'

class PersonaTest < ActionDispatch::IntegrationTest
  setup do
    #require 'capybara/poltergeist'
    Capybara.current_driver = :selenium
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
  end


  private
  def login(email=users(:alice).primary_email)
    Capybara.default_wait_time = 20 # persona login could take some time
    within('.navbar') do
      click_link('you are not logged in')
      click_link('Log In')
    end
    #page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    main_window, persona_popup = page.driver.browser.window_handles
    within_window(persona_popup) do
      fill_in('email', :with => email)
      click_button('next')
    end
    within_window(main_window) do
      within('.navbar') do
        # wait till the login completed: this could take some time
        page.has_content?(email)
      end
    end
  ensure
    Capybara.default_wait_time = 5
  end
end