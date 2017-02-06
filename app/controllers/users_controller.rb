class UsersController < ApplicationController
  def index
    @users = User.with_headers(api_auth_headers) do
      User.all
    end
  end
end
