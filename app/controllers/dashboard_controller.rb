class DashboardController < ApplicationController
  before_filter :check_authorization

  def index
    @title = "my dashboard"
  end
end
