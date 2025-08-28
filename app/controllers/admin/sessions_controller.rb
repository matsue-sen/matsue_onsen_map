# app/controllers/admin/sessions_controller.rb
class Admin::SessionsController < ApplicationController
  def new
    # パスワード入力フォーム
  end

  def create
    if params[:password] == ENV["ADMIN_PASSWORD"]
      session[:admin_authenticated] = true
      redirect_to admin_root_path, notice: "ログイン成功"
    else
      flash[:alert] = "パスワードが違います"
      render :new
    end
  end

  def destroy
    session.delete(:admin_authenticated)
    redirect_to root_path, notice: "ログアウトしました"
  end


  # セッションリセット
  def reset_admin_session
    session[:admin_authenticated] = nil
  end
end
