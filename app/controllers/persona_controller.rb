require 'net/http'

class PersonaController < ApplicationController

  def login
    # TODO: handle invalid assertion + add to log
    verify_assertion or return
    @user = User.find_by_email(@email)

    if @user
      successful_login_message
    else
      new_login_message
      @user = User.create_account(@email)
    end

    session[:email] = @email
    session[:id] = @user.id
    ajax_login_redirect params[:referer]
  end

  # TODO: remove/refactor
  #def login_and_add_email
    # the user logged into a new account and wants to add the
    # email address used in the previous step (session[:new_email]) to it
    #verify_assertion or return
    #user = User.find_by_email(@email)
    #if user
    #  user.add_email(session[:new_email])
    #  # update session info: logged in
    #  session[:id] = user.id
    #  session[:email] = @email
    #  session[:new_email] = nil
    #  # redirect to original page and remove the url from the session
    #  referer = session[:referer]
    #  session[:referer] = nil
    #  successful_login_message
    #  ajax_login_redirect referer
    #else
    #  # TODO: not really the right thing to do...
    #  flash[:warn] = 'TODO, improve this case'
    #  ajax_login_redirect '/persona/new_user'
    #end
  #end

  def logout
    flash[:info] = 'Logged out'

    session[:email] = nil
    session[:id] = nil

    render_nothing
  end

private
  def render_nothing
    render text: ''
  end

  def successful_login_message(email=nil)
    @email = email || @email
    email = CGI::escapeHTML(@email)
    flash[:success] = "Successfully logged in with <strong>#{email}</strong>".html_safe
  end

  def new_login_message
    email = CGI::escapeHTML(@email)
    flash[:success] = ("A new account has been created for <strong>#{email}</strong>. " +
        "If you already have an account add #{email} to you existing account (TODO: link).").html_safe
  end

  def verify_assertion
    assertion = params[:assertion]
    audience = request.host
    #puts "Assertion: #{assertion}"
    #puts "Audience: #{audience}"

    use_proxy = `iwconfig wlan2` =~ /GenuaWifi/
    proxy, port = use_proxy ? ['wifiproxy.unige.it', 80] : [nil, nil]
    http = Net::HTTP.new('verifier.login.persona.org', 443, proxy, port)

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
      @email = @res['email']
    end
  end

  # answer to the ajax call
  # that will trigger the javascript to redirect to the given page
  def ajax_login_redirect(url)
    render text: url
  end
end