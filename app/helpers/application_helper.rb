module ApplicationHelper
  def github_enabled?
    ENV['GITHUB_KEY'] ? true : false
  end
  def google_enabled?
    ENV['GOOGLE_CLIENT_ID'] ? true : false
  end
end
