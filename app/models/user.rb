class User < JsonResourceBase
  def full_name
    send(:'full-name')
  end
end
