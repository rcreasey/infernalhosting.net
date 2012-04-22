class PanelController < ApplicationController
  before_filter :login_required

  def index
    @user = User.find_by_id(session[:user])
  end
end
