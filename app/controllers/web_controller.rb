class WebController < ApplicationController
  before_filter :login_required
  before_filter :check_domain_ownership

  # If a domain is already specified, redirect to the web site editor
  # Otherwise, redirect to the domain overview to select a domain to manage
  def index
    if params[:origin]
      list
      render :action => 'list'
    else
      redirect_to :controller => 'domain'
    end
  end

  # List the mailboxes for the specified domain
  #
  def list
    @domain = DnsZone.find_by_origin(params[:origin])
    @title = "#{@domain.name} :: manage sites"
  end

  ## Sites

  # Create a new Site for the specified domain
  #
  def new_site
    @domain = DnsZone.find_by_origin(params[:origin])
    @site = WebSite.new

    render :layout => false
  end

  # Edit a particular mailbox
  #
  def edit_site
    @domain = DnsZone.find_by_origin(params[:origin])
    @site = WebSite.find_by_id( params[:id] )

    render :layout => false
  end

  # Creates a new site
  #
  def create_site
    @domain = DnsZone.find_by_origin(params[:origin])
    @site = WebSite.new( params[:site] )
    @site.quota_bytes = 0
    @site.user_id = session[:user]

    if @site.save
      flash[:notice] = 'Site was successfully created.'
    end

    if params["aliases"] = "true"
			@domain.service_records_by_name('www').each {|name, id| WebAlias.new( :web_site_id => @site.id, :dns_resource_id => id) }
    end

    render :partial => 'list_sites', :layout => false
  end

  # Updates the new site
  #
  def update_site
    @domain = DnsZone.find_by_origin(params[:origin])
    @site = WebSite.find( params[:id] )

    if params[:delete]
      @site.destroy
      flash[:notice] = 'Site was deleted.'

    elsif @site.update_attributes( params[:site] )
      flash[:notice] = 'Site was successfully updated.'
    end

    render :partial => 'list_sites', :layout => false
  end

end
