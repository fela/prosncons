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
    if res['status'] == 'okay'
      session[:email] = res['email']
    end

    render_nothing
  end
  def destroy
    puts "Logging out!!!"
    session[:email] = nil
    render_nothing
  end

private
  def render_nothing
    render text: ''
  end
end