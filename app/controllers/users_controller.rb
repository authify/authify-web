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

  def reset_password
    user = User.find(current_user['uid'])
    if params[:reset][:password1] == params[:reset][:password2]
      user.password = params[:reset][:password1]
      user.save
      flash[:success] = 'Password Reset'
    else
      flash[:alert] = 'Password Reset Failed! Passwords must match.'
    end
    redirect_to me_path
  end
end
