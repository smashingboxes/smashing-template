require "rails_helper"

describe "User Sign In", type: :request do
  describe "POST /api/v1/users/sign_in" do
    context "valid credentials" do
      include_context "with valid sign in credentials"
      it_behaves_like "a valid sign in"
    end
  end
end
