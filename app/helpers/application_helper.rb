module ApplicationHelper
  def header_text
    header  = "infernalhosting.net"
    header += " :: #{@title.downcase}" if @title
    return header
  end
  
  def navigation_list
    list = []

    list << content_tag(:li, link_to("My Dashboard", dashboard_url)) if logged_in?

    list << content_tag(:li, link_to("Services", services_url))
    list << content_tag(:li, link_to("About", about_url))
    list << content_tag(:li, link_to("Support", support_url))
    list << content_tag(:li, link_to("Contact", contact_url))

    unless logged_in?
      list << content_tag(:li, link_to("Login", login_url))
    else
      list << content_tag(:li, link_to("Logout", logout_url))
    end

    content_tag(:ul, list.join, :id => 'navigation')
  end
  
  def footer
    content_tag(:div, "&#169; 2008 " + link_to('Infernal Hosting', 'http://infernalhosting.net/')  , :id => 'footer')
  end
  
  def flash_notice
    if flash[:notice]
      notice = flash[:notice]
      flash.clear
      content_tag(:div, notice, :id => 'errorExplanation')
    end
  end
  
  def html_error
    case params[:code]
      when '404' then
        summary = "File Not Found"
        description = "The request you have made cannot be found on this server."
      when '500' then
        summary = "Service Temporarily Unavailable"
        description = "The server is temporarily unable to service your request due to maintenance downtime or capacity problems. Please try again later."
      else
        summary = "Error Unknown"
        description = "How did you even trigger this error?"
    end

    [content_tag(:h2, "Error #{params[:code]}"), content_tag(:h4, summary), content_tag(:p, description)]
  end
  
  
  def all_error_messages_for *models
    errors = []

    for object_name in models
      object = instance_variable_get("@#{object_name.to_s}")
      unless object.errors.empty?
        object.errors.full_messages.each { |error| errors << error}
      end
    end

    unless errors.empty?
      content_tag(:div,
        content_tag(:h2, "There seems to be something wrong...") +
        content_tag(:p, "There were problems with the following fields:") +
        content_tag(:ul, errors.collect {|e| content_tag(:li, e)}),        
        "id" =>  "errorExplanation", "class" => "errorExplanation"
      )
    end
  end
  
  def hider_toggle( text, div )
    link = link_to_function(text , nil) do |page|
      page.visual_effect :toggle_blind, div, :duration => 0.2
    end
    
    content_tag(:span, link, :class => 'trigger')
  end
end
