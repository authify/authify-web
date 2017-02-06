class JsonResourceBase < JsonApiClient::Resource
  self.site = "#{AUTHIFY_API_URL}/"
end
