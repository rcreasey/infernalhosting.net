class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  layout :select_layout

  def show_splash
    render :action => 'splash', :layout => 'splash'
  end

  protected
  # Checks the ownership of this domain
  #
  # * params[:origin] - name of the origin; ie: 'infernalhosting.net'
  def check_domain_ownership
    redirect_to :controller => '/eatmyshit' if DnsZone.find_by_origin( params[:origin] ).user_id != session[:user]
  end

  private
  # Chooses the main layout for the render
  #
  def select_layout
    layout = "xhtml" if ! params[:ajax]
  end

end
