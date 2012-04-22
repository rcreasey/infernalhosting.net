class DnsResource < ActiveRecord::Base
    belongs_to :dns_zone

    self.inheritance_column = "inheritance_type"

    def type
      self['type']
    end
end
