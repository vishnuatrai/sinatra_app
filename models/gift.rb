class Gift
  include Mongoid::Document

  field :product,  type: String
  field :brand,   type: String
  field :description, type: String
  field :image_url, type: String
  field :url, type: String
  field :row_order, type: Integer
  
  belongs_to :occasion

  def from_params(params)
    return nil unless params[:product] and params[:brand] and params[:description]

    self.product   = params[:product]
    self.brand    = params[:brand]
    self.description  = params[:description]
    return self.save
  end

  def update_from_params(params)
    self.product = params[:product] if params[:product]
    self.brand = params[:brand] if params[:brand]
    self.description = params[:description] if params[:description]
    return self.save
  end

  def to_hash
    {
      :id => self.id,
      :product => self.product,
      :brand => self.brand,
      :description => self.description
    }
  end

  def to_json
    return to_hash.to_json
  end
end
