# Table name: dns_resource_types
#
#  id          :integer(11)   not null, primary key
#  name        :string(255)   not null
#  description :text
#

class DnsResourceType < ActiveRecord::Base
  
  validates_presence_of :name
  validates_format_of :name, :with => /(A|AAAA|CNAME|HINFO|MX|NS|PTR|SRV|TXT)/

end
