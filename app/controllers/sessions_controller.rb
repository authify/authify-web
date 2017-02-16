class SessionsController < ApplicationController
  skip_before_action :setup_munson, except: [:omniauth_callback]
  layout 'minimal'

  def new
    @callback_url = callback_url(params[:callback])
    session[:before_register] = @callback_url.to_s
  end

  def create
    token = begin
      authenticate_by_password(params[:session][:email], params[:session][:password])
    rescue RestClient::Unauthorized => e
      nil
    end
    
    if token
      rurl = URI(params[:session][:callback])
      rurl.query = rurl.query ? rurl.query + "jwt=#{token}" : "jwt=#{token}"
      redirect_to rurl.to_s
    else
      # TODO track failed logins in session or on server...
      @callback_url = params[:session][:callback]
      flash.now[:danger] = 'Invalid credentials'
      render 'new'
    end
  end

  def signup
    @callback_url = callback_url(params[:callback])
  end

  def register
    email = params[:registration][:email]
    name = params[:registration][:name]
    password = params[:registration][:password]

    token = User.register(email, name, password)
    if token
      rurl = URI(params[:registration][:callback])
      rurl.query = rurl.query ? rurl.query + "jwt=#{token}" : "jwt=#{token}"
      redirect_to rurl.to_s
    else
      raise 'Registration Failed'
    end
  end

  def callback
    verify_token params[:jwt]
    setup_munson
    next_path = session[:before_login]
    session.delete(:before_login)
    redirect_to next_path ? next_path : root_path
  end

  def omniauth_callback
    auth = request.env["omniauth.auth"]

    if current_user
      # Adding a new identity to an existing user
      if current_user['username'].downcase != auth['info']['email'].downcase
        redirect_to me_path, alert: "Identity Primary Email does not match #{current_user['username'].downcase}!"
      else      
        ident = Identity.new(provider: auth[:provider], uid: auth[:uid])
        ident.save
        flash[:notice] = "Now Associated with #{auth[:provider]}:#{auth[:uid]}!"
        redirect_to me_path
      end
    else
      # Logging in / registering via an identity

      identities = Identity.include(:user).fetch
      # TODO Should be moved to an API-side filter
      user_ident = identities.select {|ident| ident.provider == auth[:provider] && ident.uid == auth[:uid]}.first

      token = if user_ident
        User.token_from_identity(auth[:provider], auth[:uid])
      else
        User.register(auth['info']['email'], auth['info']['name'], nil, auth)
      end

      if token
        rurl = URI(session[:before_register])
        session.delete(:before_register)
        verify_token(token)
        setup_munson
        rurl.query = rurl.query ? rurl.query + "jwt=#{token}" : "jwt=#{token}"
        redirect_to rurl.to_s
      else
        raise 'Registration Failed'
      end
    end
  end

  def destroy
    reset_session
    flash[:alert] = 'You have been logged out'
    redirect_to login_path
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  private

  def skip_auth?
    !['destroy'].include? action_name
  end
end
