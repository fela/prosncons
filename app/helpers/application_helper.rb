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
  def persona_email_js
    # (' "email@doamin.con" ' or 'null') as a string
    session[:email] ? '"'.html_safe + session[:email] + '"'.html_safe : 'null'
  end
end
