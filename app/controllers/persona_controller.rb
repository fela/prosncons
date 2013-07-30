require 'net/http'

class PersonaController < ApplicationController

  def login
    handle_login
  end

  def login_and_add_email
    handle_login true
  end

  def handle_login link_old_address=false
    old_email = session[:email]
    verify_assertion or return
    user = User.find_by_email(@email)
    if user
      # existing primary login
      successful_login_message
      user.add_email(old_email) if link_old_address
    else
      # first use: create account
      new_login_message
      user = User.create_account(@email)
    end

    session[:email] = @email
    session[:id] = user.id
    render_nothing
  end

  def logout
    session[:email] = nil
    session[:id] = nil

    render_nothing('Logged out')
  end

private
  def render_nothing(info=nil)
    flash[:info] = info
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
        "If you already have an account with a different email address you can " +
        "<a id='login_add' href='/js'>add #{email} " +
        "to your existing account.</a>").html_safe
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