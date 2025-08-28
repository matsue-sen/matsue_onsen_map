class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Disable browser restrictions in development environment
  allow_browser versions: :modern unless Rails.env.development?

  private

  def reset_admin_session
    session.delete(:admin_authenticated)
  end
end
