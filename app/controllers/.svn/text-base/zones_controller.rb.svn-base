class ZonesController < ApplicationController
  before_filter :check_authorization
  before_filter :load_zones, :only => [ :index, :list ]
  before_filter :load_zone_by_id, :only => [ :show, :edit, :update, :destroy ]
  before_filter :load_zone_by_origin, :only => [ :show_by_origin ]

  protected
    def load_zone_by_id
      @zone = DnsZone.find_by_id( params[:id] ) or raise ActiveRecord::RecordNotFound
    end

    def load_zone_by_origin
      @zone = DnsZone.find_by_origin( params[:origin] ) or raise ActiveRecord::RecordNotFound
    end
    
    def load_zones
      @zones = DnsZone.find(:all, :order => 'origin')
    end

  public
    def index
      render :action => 'list'
    end
    
    def show_by_origin
      respond_to do |format|
        format.html { render :action => 'show' }
        format.xml  { render :xml => @zone.to_xml }
        format.txt  { render :action => 'show', :layout => false }
      end
    end
  
    def show
      respond_to do |format|
        format.html { render :action => 'show' }
        format.xml  { render :xml => @zone.to_xml }
        format.txt  { render :action => 'show', :layout => false }
      end
    end

    def list
      respond_to do |format|
        format.html { render :action => 'list' }
        format.xml  { render :xml => @zones.to_xml }
      end
    end

    def edit
      render :action => 'edit'
    end

    def update
      update = @zone.update_attributes( params[:zone] )
      
      params[:dns_resources].each do |id, r|
        if id.eql? 'new'
          record = r.merge({:dns_resource_type => DnsResourceType.find_by_id(r[:dns_resource_type_id])})
          record.delete("dns_resource_type_id")
          @zone.dns_resources << DnsResource.create( record ) unless r[:name].empty? and r[:ttl].empty? and r[:aux].empty? and r[:data].empty?
        else
          record = DnsResource.find_by_id( id )
          r.delete('id')
          if r[:delete].eql? "1"
            record.destroy
          else
            record.update_attributes( r )
          end
        end
      end
      
      if update
        flash[:notice] = 'Zone was successfully updated.'

        respond_to do |format|
          format.html { redirect_to zone_detail_url( @zone.origin ) }
          format.xml  { head :ok }
        end
      else
        flash[:error]  = 'Unable to save changes to zone: '
        flash[:error] += @zone.errors.collect {|field, errors| "#{field.capitalize} #{errors}"}.to_sentence

        respond_to do |format|
          format.html { render :template => 'zones/edit' }
          format.xml  { render :xml => @server.errors.to_xml }
        end
      end
    end
    
    def new
      @zone = DnsZone.new
    end
    
    def create
      @zone = DnsZone.new( params[:zone].merge(:serial => 1) )
      
      if @zone.save
        @zone.dns_resources = DnsResource.default_records.map {|r| DnsResource.create( r.merge(:dns_zone => @zone) )} if params[:dns_resources][:default].eql? "true"
        flash[:notice] = 'Zone was successfully created.'

        respond_to do |format|
          format.html { redirect_to zone_detail_path( @zone.origin ) }
          format.xml  { head :created, :location => zone_detail_path( @zone.origin ) }
        end
      else
        flash[:error] = 'Unable to create the new zone.'

        respond_to do |format|
          format.html { render :template => 'zones/new' }
          format.xml  { render :xml => @zone.errors.to_xml }
        end
      end
    end
    
    def destroy
      @zone.resources.each {|r| r.destroy }
      @zone.destroy
      flash[:notice] = 'Zone has been removed from the database.'

      respond_to do |format|
        format.html { redirect_to zones_url }
        format.xml  { head :ok }
      end
    end
end
