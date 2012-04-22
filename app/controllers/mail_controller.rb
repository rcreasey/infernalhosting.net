class MailController < ApplicationController
  before_filter :login_required
  before_filter :check_domain_ownership

  # If a domain is already specified, redirec to the mailbox editor
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
    @title = "#{@domain.name} :: manage mail"
  end

  ## Mailboxes

  # Create a new Mailbox for the specified domain
  #
  def new_mailbox
    @domain = DnsZone.find_by_origin(params[:origin])
    @mailbox = MailUser.new

    render :layout => false
  end

  # Edit a particular mailbox
  #
  def edit_mailbox
    @domain = DnsZone.find_by_origin(params[:origin])
    @mailbox = MailUser.find_by_id( params[:id] )

    render :layout => false
  end

  # Creates a new mailbox
  #
  def create_mailbox
    @domain = DnsZone.find_by_origin(params[:origin])
    @mailbox = MailUser.new( params[:mailbox] )
    @mailbox.encrypt_password
    @mailbox.user_id = session[:user]

    if @mailbox.save
      flash[:notice] = 'Mailbox was successfully created.'
    end

    render :partial => 'list_mailboxes', :layout => false
  end

  # Updates the new mailbox
  #
  def update_mailbox
    @domain = DnsZone.find_by_origin(params[:origin])
    @mailbox = MailUser.find( params[:id] )

    if params[:delete]
      @mailbox.destroy
      flash[:notice] = 'Mailbox was deleted.'

    elsif @mailbox.update_attributes( params[:mailbox] )
      # re-hash password if set
      if ! params[:mailbox][:password].nil?
        @mailbox.encrypt_password
        @mailbox.save!
      end

      flash[:notice] = 'Mailbox was successfully updated.'
    end

    render :partial => 'list_mailboxes', :layout => false
  end

  ## Aliases 

  # Creates a new alias
  #
  def new_alias
    @domain = DnsZone.find_by_origin(params[:origin])
    @alias = MailAlias.new

    render :layout => false
  end

  # Edits a particular alias
  #
  def edit_alias
    @domain = DnsZone.find_by_origin(params[:origin])
    @alias = MailAlias.find_by_id( params[:id] )

    render :layout => false
  end

  # Create a new mail alias
  #
  def create_alias
    @domain = DnsZone.find_by_origin( params[:origin] )
    @alias = MailAlias.new( params[:alias] )
    @alias.user_id = session[:user]

    if @alias.save
      flash[:notice] = 'Mail Alias was successfully created.'
    end

    render :partial => 'list_aliases', :layout => false
  end

  # Updates the mail alias
  #
  def update_alias
    @domain = DnsZone.find_by_origin( params[:origin] )
    @alias = MailAlias.find( params[:id] )

    if params[:delete]
      @alias.destroy
      flash[:notice] = 'Mail Alias was deleted.'

    elsif @alias.update_attributes( params[:alias] )
      flash[:notice] = 'Mail Alias was successfully updated.'
    end

    render :partial => 'list_aliases', :layout => false
  end

end
