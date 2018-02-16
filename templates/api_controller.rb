class Api::V1::ApiController < ApplicationController
  include RenderHelper
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!
end
