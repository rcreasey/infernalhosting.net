class WebSite < ActiveRecord::Base
  belongs_to :user
  belongs_to :dns_resource
  has_many :web_alias

  ## shorthand formatting functions

  # displays the domain for the mailbox
  #
  def domain
    sprintf("%s%s%s", self.dns_resource.name, !self.dns_resource.name.empty? ? '.' : '', self.dns_resource.dns_zone.origin)
  end

end
