module ApplicationHelper

  # Twitter Bootstrap glyphs
  def glyph(*names)
    content_tag :i, nil, class: names.map{|name| "icon-#{name.to_s.gsub('_','-')}" }
  end

  # ref for links that will be overwritten by js
  def javascript_link
    '/error/enable-javascript'
  end

  # the email passed to document.id.watch()
  def persona_email
    session[:email] || session[:new_email]
  end
end
