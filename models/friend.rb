require 'date'

class Friend
  include Mongoid::Document
  field :first_name, type: String
  field :last_name, type: String
  field :facebook_id, type: Integer

  has_many :occasions
  belongs_to :user

  def from_params(params)
    return nil unless params[:first_name] and params[:last_name] and params[:facebook_id]

    self.first_name = params[:first_name]
    self.last_name = params[:last_name]
    self.facebook_id = params[:facebook_id]
    birthday = DateTime.strptime(params[:birthday], "%m/%d/%Y")
    create_occasion(birthday)
    return self.save
  end

  def create_occasion(birthday)
    if birthday
      occasion = Occasion.new
      occasion.from_params({:name => 'birthday', :type => 'birthday', :date => birthday})
      self.occasions.push(occasion)
    end
  end

  def update_from_params(params)
    self.first_name = params[:first_name] if params[:first_name]
    self.last_name = params[:last_name] if params[:last_name]
    self.facebook_id = params[:facebook_id] if params[:facebook_id]
    self.create_occasion(params[:birthday]) if params[:birthday]
    self.save
  end

  def name
    return "#{self.first_name} #{self.last_name}"
  end


  def to_hash
    {
      :id => self.id,
      :first_name => self.first_name,
      :last_name => self.last_name,
      :facebook_id => self.facebook_id
    }
  end

  def to_json
    return to_hash.to_json
  end
end
