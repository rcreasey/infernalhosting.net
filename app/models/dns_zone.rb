class DnsZone < ActiveRecord::Base
    belongs_to :user
    has_many :dns_resources, :order => 'name, type'

    validates_presence_of     :origin

    def service_records
      DnsResource.find(:all, :include => ['dns_zone'], :order => 'dns_resources.id, dns_resources.name', :conditions => ["dns_resources.dns_zone_id = ? and (dns_resources.type = 'A' or dns_resources.type = 'CNAME')", self.id]).collect {|r| [ sprintf("%s%s%s",r.name, !r.name.empty? ? '.' : '', r.dns_zone.origin), r.id]}
    end

    def service_records_by_name(name)
      DnsResource.find(:all, :include => ['dns_zone'], :order => 'dns_resources.id, dns_resources.name', :conditions => ["dns_resources.dns_zone_id = ? and (dns_resources.type = 'A' or dns_resources.type = 'CNAME') and dns_resources.name = ?", self.id, name]).collect {|r| [ sprintf("%s%s%s",r.name, !r.name.empty? ? '.' : '', r.dns_zone.origin), r.id]}
    end

    def service_records_with_omit(omit = [])
      records = self.service_records

			# remove the matching omitions
      for pattern in omit
        records.delete_if {|record, id| record =~ /#{pattern}/}
      end

			# return the list
      records
    end

    def prices
      {:register => "$6.99", :transfer => "$6.99"}
    end

    def name
      self.origin
    end

    def sites
      WebSite.find(:all, :include => ['dns_resource'], :conditions => ['dns_resources.dns_zone_id = ?', self.id])
    end

    def mailboxes
      MailUser.find(:all, :include => ['dns_resource'], :conditions => ['dns_resources.dns_zone_id = ?', self.id])
    end

    def mailaliases
      MailAlias.find(:all, :include => ['dns_resource'], :conditions => ['dns_resources.dns_zone_id = ?', self.id])
    end

    def databases
      Array.new
    end

    def records
      self.dns_resources
    end
end
