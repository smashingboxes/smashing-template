shared_examples_for "a valid sign in" do
  context "with valid params" do
    include_context "with valid sign in credentials"
    let(:endpoint) { "/api/v1/users/sign_in" }
    let(:params) { { email: user.email, password: user.password } }
    before { post endpoint, params: params }

    it_behaves_like "a successful request" do
      let(:doc_message) { "User Sign In" }
    end

    it "returns the sign in info" do
      expect(json_response[:data]).to include(
        id: user.id
      )
    end
  end
end
