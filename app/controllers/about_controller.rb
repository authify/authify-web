class AboutController < ApplicationController
  def download_jwt_key
    send_data cached_public_key.export,
              filename: 'public_key.pem',
              type: 'application/x-pem-file'
  end

  private

  def skip_auth?
    ['download_jwt_key'].include? action_name
  end
end
