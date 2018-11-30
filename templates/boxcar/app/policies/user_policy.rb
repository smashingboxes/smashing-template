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
    user.is_admin?
  end

  def update?
    user == record || user.is_admin?
  end

  def destroy?
    user.is_admin?
  end
end