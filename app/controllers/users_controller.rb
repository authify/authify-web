class UsersController < ApplicationController
  def index
    @users = User.fetch
  end

  def me
    @user = User.include(:apikeys, :identities).find(current_user['uid'])
    @identities = @user.identities
    @apikeys = @user.apikeys
  end

  # POST /users/add_api_key
  def add_api_key
    @api_key = APIKey.new
    @api_key.save
  end

  def signup
    @user = User.new
  end

  def register
  end
end
