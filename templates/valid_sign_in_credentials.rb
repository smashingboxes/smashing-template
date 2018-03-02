shared_context "with valid sign in credentials" do
  let(:user) { create(:user) }
  let(:params) { { email: user.email, password: user.password } }
end
