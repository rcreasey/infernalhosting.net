class MailAlias < ActiveRecord::Base
  belongs_to :user
  belongs_to :dns_resource

  ## shorthand formatting functions

  # displays the domain for the mailbox
  #
  def domain
    sprintf("%s%s%s", self.dns_resource.name, !self.dns_resource.name.empty? ? '.' : '', self.dns_resource.dns_zone.origin)
  end

  # displays the the full address of the mailbox
  #
  def address
    sprintf("%s@%s", self.username, self.domain)
  end


end
