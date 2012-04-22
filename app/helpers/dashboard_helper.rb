module DashboardHelper

  def dashboard_menu
    list = []
    
    list << content_tag(:li, link_to('Zones', zones_url), :class => 'admin_option')
    
    content_tag(:ul, list.join, :id => 'dashboard_menu')
  end
end
