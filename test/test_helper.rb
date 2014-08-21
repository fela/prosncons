ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'mocha/mini_test'


Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app)
end

Capybara.register_driver :chrome do |app|
  # need chrome driver
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

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


  setup do
    Capybara.default_driver = :selenium
    Capybara.default_wait_time = 5

    # problem with other drivers:
    # poltergeist doesn't provide proper multi-window
    # webkit doesn't allow the request to persona
    window = Capybara.current_session.driver.browser.manage.window
    window.resize_to(1024, 768)
  end

  private
  # option :i_will_check : use to not check the email compares on the new page
  # needed for example if the email isn't registered yet
  # make sure to do something similar that waits enough for the login
  # to finish
  def login(email=users(:alice).primary_email, opt={})
    assert find('.footer')
    main_window = page.current_window
    page.execute_script("navigator.id.request()")
    sleep 0.1
    w1, persona_popup = page.windows
    assert w1 == main_window
    within_window(persona_popup) do
      using_wait_time(2) do
        if page.has_selector?('#selectEmail')#[:id] == 'selectEmail'
          # emails used previously are being remembered
          click_on('This is not me')
        end
      end
      sleep 1
      fill_in('authentication_email', :with => email)
      click_on('next')

      unless_window_closes do
        if page.has_content?('One month')
          click_on('One month')
        end
      end
    end
    #if main_window != page.current_window
    #  page.driver.browser.switch_to.window(main_window)
    page.switch_to_window(main_window)
    login_check(email) unless opt[:i_will_check]
  end

  def logout
    within('.navbar') do
      click_on 'logged in as'
      click_on 'Log Out'
    end
    within('.navbar') do
      assert page.has_content?('you are not logged in')
    end
    within('.alert-info') do
      assert page.has_content?('Logged out')
    end
  end

  def unless_window_closes
    using_wait_time(15) do begin
      yield
    rescue Selenium::WebDriver::Error::NoSuchWindowError
      #puts 'window closed (NoSuchWindowError)'
    end end
  end

  def login_check(email)
    using_wait_time(20) do
      within('.navbar') do
        assert page.has_content?(email)
      end
    end
  end
end