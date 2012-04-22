class ErrorController < ApplicationController
  def index
    error_404
    render :action => "error_404"
  end

  def error_404
  end

  def error_503
  end
end
