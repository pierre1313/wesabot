# used by HistoryPlugin, among others
class Message
  include DataMapper::Resource
  property :id,           Serial
  property :room,         Integer, :required => true, :index => true
  property :message_id,   Integer, :required => true 
  property :message_type, String, :length => 20, :required => true, :index => true
  property :person,       String, :index => true
  property :user_id,      Integer, :required => false, :index => true
  property :link,         Text, :lazy => false
  property :body,         Text, :lazy => false
  property :timestamp,    Integer, :required => true, :index => true

  belongs_to :user, :required => false
end
