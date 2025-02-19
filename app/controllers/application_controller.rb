class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize!
  private
  def current_user
    @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
  end

  def admin?
    current_user.role == "admin"
  end
end
