module Middleware
  class AuthifyTrustedDelegate < Faraday::Middleware
    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      env[:request_headers]['X-Authify-Access'] = AUTHIFY_ACCESS_KEY
      env[:request_headers]['X-Authify-Secret'] = AUTHIFY_SECRET_KEY
      env[:request_headers]['X-Authify-On-Behalf-Of'] = @options[:email] if @options[:email]
      @app.call env
    end
  end
end
