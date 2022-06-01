class ApplicationController < ActionController::Base
  def index
    render :plain => "asdf", :layout => false
  end
end
