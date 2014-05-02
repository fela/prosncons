module ApplicationHelper

  # ref for links that will be overwritten by js
  def javascript_link
    '/js'
  end

  # the email passed to document.id.watch()
  def persona_email_js
    # (' "email@doamin.con" ' or 'null') as a string
    session[:email] ? '"'.html_safe + session[:email] + '"'.html_safe : 'null'
  end

  def link_to_user(user)
    user ? link_to(user.display_name, user) : 'anonymous'
  end

  ALERT_TYPES = %w[error info success warning]
  def display_flash
    flash_messages = []
    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = type.to_s
      type = 'success' if type == 'notice'
      type = 'error'   if type == 'alert'
      next unless ALERT_TYPES.include?(type)

      Array(message).each do |msg|
        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                               msg, :class => "alert fade in alert-#{type}")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
