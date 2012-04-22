module ZonesHelper
  def domain_list
    list = []
    @zones.each do |zone|
      content =  content_tag(:h4, link_to(zone.origin, zone_detail_path(zone.origin)))

      options = []
      options << content_tag(:li, link_to('Add Services To Domain', '#'))
      list << content_tag(:div, [content, content_tag(:ul, options, :class => 'options')], :class => 'grid-item')
    end

    list
  end
  
  def collect_dns_resource_types( resource = nil )
    selected = resource.nil? ? [] : [resource.name, resource.id]
    options_for_select DnsResourceType.find(:all, :order => 'name').map {|t| [t.name, t.id]}, selected
  end
end
