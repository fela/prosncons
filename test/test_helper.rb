ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end


# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

  private
  def login(email=users(:alice).primary_email)
    Capybara.default_wait_time = 20 # persona login could take some time
    sleep(0.2)
    page.execute_script("navigator.id.request()")
                                    #page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    main_window, persona_popup = page.driver.browser.window_handles
    within_window(persona_popup) do
      fill_in('email', :with => email)
      click_button('next')
    end
    page.driver.browser.switch_to.window(main_window)
    within('.navbar') do
      sleep(8)
      # wait till the login completed: this could take some time
      page.has_content?(email)
    end
  ensure
    Capybara.default_wait_time = 5
  end
end