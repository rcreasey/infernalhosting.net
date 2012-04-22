class DomainController < ApplicationController
  before_filter :login_required

  # If a domain is already specified, redirect to the domain overview.
  # Otherwise, display a list of hosted domains for management.
  #
  def index
    if params[:origin]
      overview
      render :action => 'overview'

    else
      list
      render :action => 'list'

    end
  end

  # Review the hosting options for the specified domain name.
  #
  def overview
    @domain = DnsZone.find_by_origin(params[:origin])
    @title = "#{@domain.name} :: overview"
  end

  # Display a list of domains attached to the user's account.
  #
  def list
    @user = User.find_by_id(session[:user])
    @domains = @user.domains
    @title = "hosted domains"
    
  end

  # Removes the domain from the database and cascades its dependencies
  #
  def destroy
    domain = DnsZone.find(params[:id])
    domain.destroy

    flash[:notice] = 'The domain has been deleted.'
    redirect_to :action => 'list'
  end

  # Add a domain to the database and redirect to the domain overview.
  #
  def add
    @title = "add a domain"

    @domain = DnsZone.new
  end

  # Creates the domain and associates it with the user.
  #
  def create
    @domain = DnsZone.new(params[:domain])
    @domain.user_id = current_user.id
    @domain.mbox = 'dns.infernalhosting.net'
    @domain.ns = 'ns0.infernalhosting.net'

    if @domain.save
      flash[:notice] = 'The domain was successfully added to your list of hosted domains.'

      if params[:defaults]
        create_defaults( @domain.id )
      end

      redirect_to :action => 'list'
    else
      render :action => 'add'
    end
  end

  # Creates the default records to be added on zone creation.
  # (could be a hook to a db call to look up profiles)
  #
  def create_defaults(zone_id)
    domain = DnsZone.find_by_id( zone_id )

    DnsResource.new(:dns_zone_id => zone_id, :name => "", :type => "A", :data => "67.15.197.146", :aux => 0, :ttl => 300).save
    DnsResource.new(:dns_zone_id => zone_id, :name => "", :type => "MX", :data => "mail.infernalhosting.net.", :aux => 0, :ttl => 300).save
    DnsResource.new(:dns_zone_id => zone_id, :name => "", :type => "NS", :data => "ns0.infernalhosting.net.", :aux => 0, :ttl => 300).save
    DnsResource.new(:dns_zone_id => zone_id, :name => "", :type => "NS", :data => "ns1.infernalhosting.net.", :aux => 0, :ttl => 300).save
    DnsResource.new(:dns_zone_id => zone_id, :name => "webmail", :type => "CNAME", :data => "webmail.infernalhosting.net.", :aux => 0, :ttl => 300).save
    DnsResource.new(:dns_zone_id => zone_id, :name => "www", :type => "CNAME", :data => domain.name.gsub(/$/, '.'), :aux => 0, :ttl => 300).save
  end


end
