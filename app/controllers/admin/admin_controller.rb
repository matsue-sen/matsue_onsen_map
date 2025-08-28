# app/controllers/admin/admin_controller.rb
class Admin::AdminController < ApplicationController
  before_action :require_admin_password





  private

  def require_admin_password
    return if session[:admin_authenticated]
    redirect_to admin_login_path
  end
end
