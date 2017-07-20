class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_user_presence
  
  protected
  
  def configure_permitted_parameters
    # Permit the `subscribe_newsletter` parameter along with the other
    # sign up parameters.
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  
  def update_user_presence
    return unless current_user
    
    current_user.last_present = Time.now
    current_user.save
  end
end
