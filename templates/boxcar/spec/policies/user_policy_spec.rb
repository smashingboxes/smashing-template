require "rails_helper"

describe UserPolicy do
  subject { described_class.new(current_user, user) }

  let(:resolved_scope) do
    described_class::Scope.new(current_user, User.all).resolve
  end

  context "for an admin" do
    let(:current_user) { create(:user, :admin) }

    context "creating a new user" do
      let(:user) { User.new }

      it { is_expected.to_not permit_action(:create) }
    end

    context "with an existing user" do
      let(:user) { create(:user) }

      it "includes the record in the resolved scope" do
        expect(resolved_scope).to include(user)
      end

      it { is_expected.to permit_actions(%i(show update)) }
      it { is_expected.to_not permit_action(:destroy) }
    end
  end

  context "for a non-admin" do
    let(:current_user) { create(:user) }

    context "creating a new user" do
      let(:user) { User.new }

      it { is_expected.to_not permit_action(:create) }
    end

    context "with an existing other user" do
      let(:user) { create(:user) }

      it "includes the record in the resolved scope" do
        expect(resolved_scope).to include(user)
      end

      it { is_expected.to_not permit_actions(%i(show update destroy)) }
    end

    context "with their own user" do
      let(:user) { current_user }

      it "includes the record in the resolved scope" do
        expect(resolved_scope).to include(user)
      end

      it { is_expected.to permit_actions(%i(show update)) }
      it { is_expected.to_not permit_action(:destroy) }
    end
  end
end