Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user:email' if ENV['GITHUB_KEY']
  #provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
end
