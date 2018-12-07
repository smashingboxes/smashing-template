# frozen_string_literal: true

require "rails_helper"

describe UserPolicy do
  subject { described_class.new(current_user, user) }

  let(:resolved_scope) do
    described_class::Scope.new(current_user, User.all).resolve
  end

  context "when current user is an admin" do
    let(:current_user) { create(:user) }

    before do
      allow(current_user).to receive(:admin?).and_return(true)
    end
    # For now, we are assuming that admins are determined by the return of a method
    # called admin? as a sane default. It is currently stubbed out in user.rb to
    # always return false, so we are over-riding that in this particular case. The
    # business logic for assigning admin access cannot be safely generalized across
    # many business cases, so this is should mostly be seen as an example test.

    context "when they attempt to create a new user" do
      let(:user) { User.new }

      it { is_expected.to permit_action(:create) }
    end

    context "with an existing user" do
      let(:user) { create(:user) }

      it "includes the record in the resolved scope" do
        expect(resolved_scope).to include(user)
      end

      it { is_expected.to permit_actions(%i[index show create update destroy]) }
    end
  end

  context "when the current user is not an admin" do
    let(:current_user) { create(:user) }

    context "when they attempt to create a new user" do
      let(:user) { User.new }

      it { is_expected.to_not permit_action(:create) }
    end

    context "with an existing other user" do
      let(:user) { create(:user) }

      it "includes the record in the resolved scope" do
        expect(resolved_scope).to include(user)
      end

      it { is_expected.to_not permit_actions(%i[create update destroy]) }
    end

    context "when they are acting upon their own record" do
      let(:user) { current_user }

      it "includes the record in the resolved scope" do
        expect(resolved_scope).to include(user)
      end

      it { is_expected.to permit_actions(%i[show update]) }
      it { is_expected.to_not permit_action(:destroy) }
    end
  end
end