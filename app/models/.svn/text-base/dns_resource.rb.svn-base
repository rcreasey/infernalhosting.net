# Table name: dns_resources
#
#  id                    :integer(11)   not null, primary key
#  dns_zone_id           :integer(11)   not null, foreign key
#  dns_resource_type_id  :integer(11)   not null, foreign key
#  name                  :string(64)    not null
#  data                  :string(255)   not null
#  aux                   :integer(11)
#  ttl                   :integer(11)
#

class DnsResource < ActiveRecord::Base
  belongs_to :dns_zone
  belongs_to :dns_resource_type
  
  validates_presence_of     :dns_zone_id, :dns_resource_type_id
  validates_presence_of     :data
  validates_numericality_of :aux, :ttl
  
  # shorthand methods
  #
  def resource_type
    self.dns_resource_type.name
  end
  
  def self.default_records
    defaults = []
    defaults << {:dns_resource_type_id => 1, :name => '', :data => '72.232.239.133', :aux => 0, :ttl => 300}
    defaults << {:dns_resource_type_id => 6, :name => '', :data => 'ns0.infernalhosting.net', :aux => 0, :ttl => 300}
    defaults << {:dns_resource_type_id => 6, :name => '', :data => 'ns1.infernalhosting.net', :aux => 0, :ttl => 300}
    defaults << {:dns_resource_type_id => 5, :name => '', :data => 'mail.infernalhosting.net', :aux => 0, :ttl => 300}
    defaults << {:dns_resource_type_id => 3, :name => 'mail', :data => 'mail.infernalhosting.net', :aux => 0, :ttl => 300}
  end
  
  ## formatting methods
  #
  def formatted_data
    case resource_type
      when "A" then data # IPv4
      when "AAAA" then data # IPv6
      when "CNAME" then data =~ /\.$/ ? data : data.gsub(/$/,'.') # alias to name
      when "HINFO" then '"' + data + '"' # text field
      when "MX" then data =~ /\.$/ ? data : data.gsub(/$/,'.') # alias to name
      when "NS" then data =~ /\.$/ ? data : data.gsub(/$/,'.') # alias to name
      when "PTR" then data # IPv4 or IPv6 address
      when "SRV" then data # would be 'port target'
      when "TXT" then '"' + data + '"' # text field
      else data # general case
    end
  end
  
  def to_xml( options = {} )
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:ident])
    xml.instruct! unless options[:skip_instruct]
    xml.resource do
      xml.id( id, :type => 'integer' )
      xml.name( name )
      xml.type( resource_type )
      xml.data( data )
      xml.aux( aux, :type => 'integer' ) unless aux.nil?
      xml.ttl( ttl, :type => 'integer' ) unless ttl.nil?
    end
  end

  def to_txt
    wire = []
    wire << name
    wire << ttl unless ttl.to_i < dns_zone.ttl.to_i
    wire << "IN" # could be HS or CH historically
    wire << resource_type
    wire << aux unless aux.eql? 0 and !resource_type.eql? 'MX'
    wire << formatted_data
    
    wire.join("\t")
  end
end
