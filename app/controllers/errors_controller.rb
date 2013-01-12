class ErrorsController < ApplicationController
  def not_found
    render :template => 'errors/404', :layout => false
  end

  def unprocessable
    render :template => 'errors/422', :layout => false
  end

  def internal_error
    render :template => 'errors/500', :layout => false
  end
end
