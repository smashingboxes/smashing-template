class Api::V1::Users::SessionsController < DeviseTokenAuth::SessionsController
  include RenderHelper
  include DeviseTokenAuthResponseSerializer
end
