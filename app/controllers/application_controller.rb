class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorization_init

  def authorization_init
    # make sure it is run at most once
    return if @authorization_init_run
    @authorization_init_run = true

    @logged_in_user = session[:id] && User.find(session[:id])
    #puts '--------------'
    #puts request.url
    #puts "session id: #{session[:id]}"
    #puts "session email: #{session[:email]}"
    #puts "primary email: #{@logged_in_user && @logged_in_user.primary_email}"
    if @logged_in_user && @logged_in_user.primary_email != session[:email]
      # logged in user didn't use primary email address
      email = CGI::escapeHTML(@logged_in_user.primary_email)
      flash[:info] = ("To be able to use you account please " +
          "<a id='login' href='/js'>log in</a> with your primary email " +
          "address <strong>#{email}</strong>").html_safe
      @secondary_login = true
    end
  rescue ActiveRecord::RecordNotFound
    session[:id] = session[:email] = @logged_in_user = nil
  end

  # used by cancan and paper_trail
  def current_user
    # authorization initialization if not run yet
    # (in the case of paper_trial it might not have run)
    authorization_init
    @logged_in_user
  end
end
