require 'auth_middleware'
Munson.configure(url: AUTHIFY_API_URL.to_s)
Linguistics.use(:en)

# ActiveRecord ActiveModel::Name compatibility methods
class Munson::Resource
  def self.human
    i18n_key.humanize
  end

  def self.i18n_key
    self.name.split('::').last.underscore
  end

  def self.param_key
    singular_route_key.to_sym
  end

  def self.route_key
    singular_route_key.en.plural
  end

  def self.singular_route_key
    self.name.split('::').last.underscore
  end

  def model_name
    self.class
  end

  def new?
    id ? false : true
  end

  def to_model
    self
  end

  def to_key
    new? ? [] : [id]
  end

  def to_param
    new? ? nil : id.to_s
  end

  def self.via_munson(user = nil)
    opts = { url: AUTHIFY_API_URL.to_s, response_key_format: :dasherize }
    email = user ? user['username'] : nil
    connection = Munson::Connection.new(opts) do |c|
      c.use Middleware::AuthifyTrustedDelegate, email: email
    end
    munson.connection = connection
    yield self
  end
end

class Munson::Collection
  def size
    @collection.size
  end
end
