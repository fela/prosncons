class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorization_init

  def authorization_init
    @logged_in_user = session[:id] && User.find(session[:id])
  rescue ActiveRecord::RecordNotFound
    session[:id] = session[:email] = @logged_in_user = nil
  end
end
