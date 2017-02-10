class UsersController < ApplicationController
  def index
    @users = User.fetch
  end

  def me
    @user = User.include(:identities, :'api-keys').find(current_user['uid'])
  end

  def signup
    @user = User.new
  end

  def register
  end
end
