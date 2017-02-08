class UsersController < ApplicationController
  def index
    @users = User.with_headers(api_auth_headers) do
      User.all
    end
  end

  def me
    @user = User.with_headers(api_auth_headers) do
      User.find(current_user['uid']).first
    end
  end
end
