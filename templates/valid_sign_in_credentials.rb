shared_context "with valid sign in credentials" do
  let(:params) { { email: user.email, password: password } }
end
