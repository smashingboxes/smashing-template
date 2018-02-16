shared_examples "a valid sign in" do
  context "with valid params" do
    let(:endpoint) { "/api/v1/users/sign_in" }
    let(:password) { "Secur3P@ssw0rd" }
    let(:user) { create(:user, password: password) }

    before { post endpoint, params: params }

    let(:params) { { email: user.email, password: password } }

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
