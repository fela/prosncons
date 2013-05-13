ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'


Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  if `iwconfig wlan2` =~ /GenuaWifi/
    profile["network.proxy.type"] = 1 # manual proxy config
    profile["network.proxy.http"] = "genuawifi.unige.it"
    profile["network.proxy.http_port"] = 80
  end

  Capybara::Selenium::Driver.new(app, :profile => profile)
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

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

  private
  # option :i_will_check : use to not check the email compares on the new page
  # needed for example if the email isn't registered yet
  # make sure to do something similar that waits enough for the login
  # to finish
  def login(email=users(:alice).primary_email, opt={})
    assert find('.footer')
    page.execute_script("navigator.id.request()")
    main_window, persona_popup = page.driver.browser.window_handles
    within_window(persona_popup) do
      using_wait_time(2) do
        if page.has_selector?('#selectEmail')#[:id] == 'selectEmail'
          # emails used previously are being remembered
          puts 'clicking...'
          click_on('thisIsNotMe')
          puts 'clicked'
        end
      end
      sleep 1
      fill_in('authentication_email', :with => email)
      click_on('next')

      puts 'aaa'
      using_wait_time(15) do begin
        if page.has_content?('One month')
          click_on('One month')
        end
      #rescue Selenium::WebDriver::Error::NoSuchWindowError
      rescue Selenium::WebDriver::Error::UnknownError => e
        p 'unknown error catched'
        # do nothing if window closes
      end end
    end
    puts 'okk'
    page.driver.browser.switch_to.window(main_window)
    login_check(email) unless opt[:i_will_check]
  end

  def login_check(email)
    using_wait_time(20) do
      within('.navbar') do
        assert page.has_content?(email)
      end
    end
  end
end