class User
  include DataMapper::Resource
  property :id,          Serial
  property :name,        String, :index => true
  property :campfire_id, Integer, :index => true

  has n, :messages
end
