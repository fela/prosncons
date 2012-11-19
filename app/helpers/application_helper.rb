module ApplicationHelper

  # Twitter Bootstrap glyphs
  def glyph(*names)
    content_tag :i, nil, class: names.map{|name| "icon-#{name.to_s.gsub('_','-')}" }
  end

  # ref for links that will be overwritten by js
  def javascript_link
    '/js'
  end

  # the email passed to document.id.watch()
  def persona_email
    session[:email] || session[:new_email]
  end

  def persona_need_to_log_out
    session[:new_email] && !session[:email] && !@stay_logged_in
  end
end
