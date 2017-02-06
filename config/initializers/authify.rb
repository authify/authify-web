AUTHIFY_PUBLIC_URL = URI(ENV['AUTHIFY_PUBLIC_URL'] || 'http://localhost:3000')
AUTHIFY_PUBLIC_URL.freeze

AUTHIFY_API_URL = URI(ENV['AUTHIFY_API_URL'] || 'http://localhost:9292')
AUTHIFY_API_URL.freeze

AUTHIFY_ACCESS_KEY = ENV['AUTHIFY_ACCESS_KEY']
AUTHIFY_ACCESS_KEY.freeze

AUTHIFY_SECRET_KEY = ENV['AUTHIFY_SECRET_KEY']
AUTHIFY_SECRET_KEY.freeze

AUTHIFY_JWT_ISSUER = ENV['AUTHIFY_JWT_ISSUER']
AUTHIFY_JWT_ISSUER.freeze
