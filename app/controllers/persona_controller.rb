require 'net/http'

class PersonaController < ApplicationController

  def login
    verify_assertion or return
    @user = User.find_by_email(@email)
    if @user
      # normal login
      session[:email] = @email
      session[:id] = @user.id
      successful_login_message
      ajax_login_redirect params[:referer]
    else
      # new user
      # redirect user to page asking if he wants to create an account
      # or if he wants to link it to an existing one
      session[:new_email] = @email
      session[:referer] = params[:referer]
      ajax_login_redirect '/persona/new_user'
    end
  end

  def new_user
    @stay_logged_in = true
    expires_now
    puts session[:new_email]
    unless session[:new_email]
      redirect_to (session[:referer] || root_url)
    end
  end

  def create_account
    # XXX: should be POST
    # user choose to create a new account
    user = User.create_account(session[:new_email])
    if user && session[:new_email]
      session[:id] = user.id
      session[:email] = session[:new_email]
      session[:new_email] = nil
      # redirect to original page and remove the url from the session
      referer = session[:referer]
      session[:referer] = nil
      successful_login_message
      redirect_to referer
    else
      flash[:error] = 'Some error occurred creating the new account,' +
          'for example another page got opened while registering'
    end
  end

  def login_and_add_email
    # the user logged into a new account and wants to add the
    # email address used in the previous step (session[:new_email]) to it
    verify_assertion or return
    user = User.find_by_email(@email)
    if user
      user.add_email(session[:new_email])
      # update session info: logged in
      session[:id] = user.id
      session[:email] = @email
      session[:new_email] = nil
      # redirect to original page and remove the url from the session
      referer = session[:referer]
      session[:referer] = nil
      successful_login_message
      ajax_login_redirect referer
    else
      # TODO: not really the right thing to do...
      flash[:warn] = 'TODO, improve this case'
      ajax_login_redirect '/persona/new_user'
    end
  end

  def logout
    flash[:info] = 'Logged out'

    silent_log_out
  end

  def silent_log_out # no flash message
    session[:email] = nil
    session[:id] = nil
    session[:new_email] = nil

    render_nothing
  end

private
  def render_nothing
    render text: ''
  end

  def successful_login_message
    @email = CGI::escapeHTML(@res['email'])
    flash[:success] = "Successfully logged in with <strong>#@email</strong>".html_safe
  end

  def verify_assertion
    assertion = params[:assertion]
    audience = request.host
    #puts "Assertion: #{assertion}"
    #puts "Audience: #{audience}"
    http = Net::HTTP.new('verifier.login.persona.org', 443)
    http.use_ssl = true
    headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
    }
    data = "audience=#{audience}&assertion=#{assertion}"
    resp = http.post("/verify", data, headers)
    @res = JSON.parse(resp.body())
    if @res['audience'] != audience
      a = @res['audience']
      flash[:error] = "Error with Persona login: invalid audience #{a}"
      ajax_login_redirect params[:referer]
      nil
    elsif @res['status'] != 'okay'
      flash[:error] = 'Error with Persona login: ' + @res['reason']
      ajax_login_redirect params[:referer]
      nil
    else
      @email
    end
  end

  # answer to the ajax call
  # that will trigger the javascript to redirect to the given page
  def ajax_login_redirect(url)
    render text: url
  end
end