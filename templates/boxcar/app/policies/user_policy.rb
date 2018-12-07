# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # NOTE: In this context, `user` is the currently signed in user, whereas `record` is the user
  # we're trying to determine permissions for

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin?
  end

  def update?
    user == record || user.admin?
  end

  def destroy?
    user.admin?
  end
end