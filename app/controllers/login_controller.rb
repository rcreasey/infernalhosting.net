class LoginController < ApplicationController

  def index
    render :action => "login"
  end

  def login
    @title = 'Login' 

    if params[:user][:username]
      self.current_user = User.authenticate(params[:user][:username], params[:user][:password])

      if logged_in?
        flash[:notice] = "Logged in successfully"
        redirect_back_or_default(:controller => '/panel')

      else 
        @title = "Login Failed"

        flash[:notice] = "Your login credentials were incorrect.  Please try again."
        render :action => "login"
      end
    end

  end

  def logout
    @title = 'Logout'

    if logged_in?
      self.current_user = nil
    end

    #cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/login')
  end

end
