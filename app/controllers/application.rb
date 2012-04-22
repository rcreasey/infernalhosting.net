class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  layout 'xhtml'

  # static named routes
  def index
    render :action => 'index'
  end

  def show_services
    @title = 'services'
    render :action => 'services'
  end

  def show_about
    @title = 'about'
    render :action => 'about'
  end

  def show_support
    @title = 'support'
    render :action => 'support'
  end

  def show_contact
    @title = 'contact'
    render :action => 'contact'
  end

  def show_eula
    @title = 'eula'
    render :action => 'eula'
  end
  
  def error
    render :action => 'error'
  end

  protected
  
    def check_authorization
      unless logged_in?
        flash[:notice] = 'Sorry, but you need to log in first!'
        session[:redirect_url] = request.request_uri
        redirect_to '/'
      end
    end
    
    def check_for_https
      # this method should check the existing protocol and redirect to https if it's not already
    end
end
