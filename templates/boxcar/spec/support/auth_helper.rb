module Request
  module AuthorizedRequestHelpers
    def authenticated_get(path:, user: nil, params: nil, is_json: true)
      authenticated_request(:get, user, path, params, is_json)
    end

    def authenticated_post(path:, user: nil, params: nil, is_json: true)
      authenticated_request(:post, user, path, params, is_json)
    end

    def authenticated_put(path:, user: nil, params: nil, is_json: true)
      authenticated_request(:put, user, path, params, is_json)
    end

    def authenticated_patch(path:, user: nil, params: nil, is_json: true)
      authenticated_request(:patch, user, path, params, is_json)
    end

    def authenticated_delete(path:, user: nil, params: nil, is_json: true)
      authenticated_request(:delete, user, path, params, is_json)
    end

    private

    def authenticated_request(request_type, user, path, params, is_json)
      user ||= create(:user)
      headers = user.create_new_auth_token
      send_params = { params: params, headers: headers }
      send_params[:as] = :json if is_json
      public_send(request_type, path, send_params)
    end
  end
end

RSpec.configure do |config|
  config.include Request::AuthorizedRequestHelpers, type: :request
end
