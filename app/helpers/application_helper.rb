module ApplicationHelper
  def github_enabled?
    ENV['GITHUB_KEY'] ? true : false
  end
end
