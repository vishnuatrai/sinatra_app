UPCOMING_THRESHOLD = 60*60*24*90

class User
  include Mongoid::Document
  field :email, type: String
  field :first_name, type: String
  field :last_name,  type: String
  field :facebook_id, type: Integer
  field :facebook_token, type: String

  has_many :friends
  has_many :gifts

  def occasions
    occasions = []
    friends.each do |friend|
      friend.occasions.each {|o| occasions << o}
    end
    occasions
  end

  def upcoming_occasions
    upcoming = []
    friends.each do |friend|
      friend.occasions.each do |o|
        if o.relative_date > Time.now and
           o.relative_date < Time.now + UPCOMING_THRESHOLD
          upcoming << o
        end
      end
    end
    upcoming
  end

  def name
    return "#{self.first_name} #{self.last_name}"
  end

  def from_params(params)
    return nil unless params[:first_name] and params[:last_name] and
        params[:facebook_id] and params[:facebook_token]

    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.facebook_id = params[:facebook_id]
    self.facebook_token = params[:facebook_token]
    return self.save
  end

  def update_from_params(params)
    self.first_name = params[:first_name] if params[:first_name]
    self.last_name = params[:last_name] if params[:last_name]
    self.facebook_id = params[:facebook_id] if params[:facebook_id]
    self.facebook_token = params[:facebook_token] if params[:facebook_token]
    return self.save
  end

  def to_hash
    {
      :id => self.id,
      :first_name => self.first_name,
      :last_name => self.last_name,
      :facebook_id => self.facebook_id,
      :facebook_token => self.facebook_token
    }
  end

  def to_json
    return to_hash.to_json
  end
end
