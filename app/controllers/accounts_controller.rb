class AccountsController < ApplicationController
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_account, :only => [:suspend, :unsuspend, :destroy, :purge]
  
  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token

    @account = Account.new(params[:account])
    @account.register! if @account.valid?
    
    if @account.errors.empty?
      self.current_account = @account
      render :template => 'accounts/processing'
    else
      render :action => 'signup'
    end
  end

  def activate
    flash.clear
    self.current_account = Account.find_by_activation_code(params[:activation_code])
    
    if logged_in? && !current_account.active?
      current_account.activate!
      flash[:notice] = "Sweet! Your account is now activated, and you're free to log in."
      render :template => 'accounts/completed'
    else
      flash[:notice] = "Sorry, but I couldn't activate your account!  Did you follow the link in your welcome email?"
      redirect_back_or_default login_url
    end
  end

  def suspend
    @account.suspend! 
    redirect_to accounts_path
  end

  def unsuspend
    @account.unsuspend! 
    redirect_to accounts_path
  end

  def destroy
    @account.delete!
    redirect_to accounts_path
  end

  def purge
    @account.destroy
    redirect_to accounts_path
  end

protected
  def find_account
    @account = Account.find(params[:id])
  end

end
