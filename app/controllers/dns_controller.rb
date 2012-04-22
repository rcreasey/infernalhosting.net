class DnsController < ApplicationController
  before_filter :login_required
  before_filter :check_domain_ownership 

  # If a domain is already specified, redirect to the dns editor
  # Otherwise, redirect to the domain overview to select a domain to manage
  #
  def index
    if params[:origin]
      edit
      render :action => 'edit'

    else
      redirect_to :controller => 'domain'
    end
  end

  # Edit the DNS for the specified domain
  #
  def edit
    @domain = DnsZone.find_by_origin(params[:origin], :order => 'origin')
    @title = "#{@domain.name} :: manage dns"
  end

  def soa
    @domain = DnsZone.find_by_origin(params[:origin])

    if @domain.update_attributes(params[:domain])
      flash[:notice] = "The domain's SOA values have been updated."
    end

    render :partial => 'soa'
  end

  def rr
    @domain = DnsZone.find_by_origin(params[:origin])

    # Update existing records
    if params[:updates]
      for update in params[:updates]
        record_id = update[0]
        record = DnsResource.find_by_id( record_id )
        values = update[1]
     
        if values[:delete] == "1"
          record.destroy
        else 
          values[:ttl] = values[:ttl].nil? ? nil : values[:ttl]
          values[:aux] = values[:aux].nil? ? nil : values[:aux]
          record.update_attributes( values )
        end
      end
    end

    # Add new entry, if set
    new_data = params[:new]
    if !new_data[:data].nil?
      new_record = DnsResource.new(new_data)
      new_record.dns_zone_id = @domain.id 
      new_record.ttl = new_record.ttl.nil? ? nil : new_record.ttl
      new_record.aux = new_record.aux.nil? ? nil : new_record.aux
 
      new_record.save!
    end

    flash[:notice] = "The domain's resource records have been updated."
    render :partial => 'rr'
  end

end
