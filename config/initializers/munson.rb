require 'auth_middleware'
Munson.configure(url: AUTHIFY_API_URL.to_s, response_key_format: :dasherize)
