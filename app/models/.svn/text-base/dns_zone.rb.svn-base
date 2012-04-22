# Table name: dns_zones
#
#  id         :integer(11)   not null, primary key
#  origin     :string(255)   not null
#  ns         :string(255)   not null
#  mbox       :string(255)   not null
#  serial     :integer(11)   not null
#  refresh    :integer(11)   not null, default 10800
#  retry      :integer(11)   not null, default 3600
#  expire     :integer(11)   not null, default 604800
#  ttl        :integer(11)   not null, default 3600
#  minimum    :integer(11)   not null, default 3600
#

class DnsZone < ActiveRecord::Base
  has_many :dns_resources, :order => 'name'
  
  validates_presence_of     :origin, :ns, :mbox
  validates_presence_of     :refresh, :retry, :expire, :ttl
  validates_numericality_of :refresh, :retry, :expire, :ttl
  validates_uniqueness_of   :origin
  
  ## shorthand methods
  #
  def resources
    self.dns_resources
  end
  
  ## formatting methods
  #
  def formatted_origin
    origin =~ /\.$/ ? origin : origin.gsub(/$/,'.')
  end
  
  def formatted_ns
    ns =~ /\.$/ ? ns : ns.gsub(/$/,'.')
  end
  
  def formatted_mbox
    mbox =~ /\.$/ ? mbox : mbox.gsub(/$/,'.')
  end
  
  def to_xml( options = {} )
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:ident])
    xml.instruct! unless options[:skip_instruct]
    xml.zone do
      xml.id( id, :type => 'integer' )
      xml.origin( origin )
      xml.ns( ns )
      xml.mbox( mbox )
      xml.refresh( refresh, :type => 'integer' ) unless refresh.nil?
      xml.retry( self.retry, :type => 'integer' ) unless self.retry.nil?
      xml.expire( expire, :type => 'integer' ) unless expire.nil?
      xml.ttl( ttl, :type => 'integer' ) unless ttl.nil?
      resources.to_xml(:skip_instruct => true, :builder => xml) unless resources.empty?
    end
  end
  
  def to_txt( options = {} )
  
  end
end
