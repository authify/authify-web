class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_authentication

  def authenticate_by_password(user, pass)
    # TODO handle auth errors
    response = RestClient.post "#{AUTHIFY_API_URL}/jwt/token",
              {'email' => user, 'password' => pass}.to_json,
              { content_type: :json, accept: :json }
    
    session[:authenticated] = Time.now
    JSON.parse(response.body)['jwt']
  end

  def callback_url(encoded_url)
    URI(Base64.decode64(encoded_url))
  end

  def authenticated?
    if skip_auth?
      # Don't bother with auth if we're supposed to skip it
      true
    elsif session[:last_authenticated_action] && session[:last_authenticated_action] < 1.hour.ago
      session[:last_authenticated_action] = Time.now
      true
    elsif session[:authenticated] && session[:authenticated] > 1.hour.ago
      # If they have authenticated and it hasn't expired
      session[:last_authenticated_action] = Time.now
      true
    else
      false
    end
  end

  def cached_public_key
    # TODO handle key lookup errors
    @cached_jwt_key ||= RestClient.get("#{AUTHIFY_API_URL}/jwt/key").body
    OpenSSL::PKey::EC.new @cached_jwt_key
  end

  def skip_auth?
    false
  end

  def current_user
    session[:user]
  end

  def logged_in?
    skip_auth? || (current_user && authenticated?)
  end

  def require_authentication
    unless logged_in?
      flash.now[:danger] = 'You must login to continue!'
      session[:before_login] = request.original_url
      rurl = URI(login_path)
      callback_url = AUTHIFY_PUBLIC_URL.dup
      callback_url.path = '/callback'
      rurl.query = "callback=#{Base64.encode64(callback_url.to_s).chomp}"
      redirect_to rurl.to_s
    end
  end

  def verify_token(token)
    options = {
      algorithm: 'ES256',
      verify_iss: true,
      verify_iat: true,
      iss: AUTHIFY_JWT_ISSUER
    }
    payload, _header = JWT.decode token, cached_public_key, true, options
    session[:authenticated] = Time.now
    session[:scopes] = payload['scopes']
    session[:user] = payload['user']
  end

  def api_auth_headers
    base = {
      x_authify_access: AUTHIFY_ACCESS_KEY,
      x_authify_secret: AUTHIFY_SECRET_KEY
    }
    base[:x_authify_on_behalf_of] = current_user['username'] if current_user
    base
  end
end
