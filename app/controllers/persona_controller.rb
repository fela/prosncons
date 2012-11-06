require 'net/http'

class PersonaController < ApplicationController
  def new
    assertion = params[:assertion]
    audience = request.host
    puts "Assertion: #{assertion}"
    puts "Audience: #{audience}"
    http = Net::HTTP.new('verifier.login.persona.org', 443)
    http.use_ssl = true
    headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
    }
    data = "audience=#{audience}&assertion=#{assertion}"
    resp = http.post("/verify", data, headers)
    res = JSON.parse(resp.body())
    if res['status'] == 'okay' && res['audience'] == audience
      flash[:success] = 'Successfully logged in'
      session[:email] = res['email']
      @user = User.logged_in(res['email'])
      session[:id] = @user.id
    else
      flash[:error] = 'Error logging in'
    end

    render_nothing
  end
  def destroy
    puts "Logging out!!!"
    session[:email] = nil
    flash[:info] = 'Logged out'
    render_nothing
  end

private
  def render_nothing
    render text: ''
  end
end