# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    flash[:notice] = "You have flash messages in your header!"
    flash[:alert] = "You might want to remove this in application_controller.rb #home!"
    render "shared/home"
  end
end
