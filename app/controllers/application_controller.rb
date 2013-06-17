class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorization_init

  def authorization_init
    @logged_in_user = session[:id] && User.find(session[:id])
    #puts '--------------'
    #puts request.url
    #puts "session id: #{session[:id]}"
    #puts "session email: #{session[:email]}"
    #puts "primary email: #{@logged_in_user && @logged_in_user.primary_email}"
    if @logged_in_user && @logged_in_user.primary_email != session[:email]
      # logged in user didn't use primary email address
      flash[:info] = ("To be able to use you account please " +
          "<a id='login' href='/js'>log in</a> with your primary email " +
          "address <strong>#{@logged_in_user.primary_email}</strong>").html_safe
      @secondary_login = true
    end
  rescue ActiveRecord::RecordNotFound
    session[:id] = session[:email] = @logged_in_user = nil
  end
end
