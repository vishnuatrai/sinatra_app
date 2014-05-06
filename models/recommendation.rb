class Recommendation
  include Mongoid::Document
  field :name, type: String
  field :source, type: String
  field :url, type: String
  field :image_url, type: String
  field :description, type: String
  field :row_order, type: Integer

  belongs_to :occasion

  def from_hunch(data)
    return nil unless data["name"] and data["url"] and data["image_url"]

    self.source       = "hunch"
    self.name         = data["name"]
    self.url          = data["url"]
    self.image_url    = data["image_url"]
    self.description  = data["description"] if data["description"]
    return self.save
  end

  def to_hash
    {
      :id           => self.id,
      :source       => self.source,
      :name         => self.name,
      :url          => self.url,
      :image_url    => self.image_url,
      :description  => self.description
    }
  end

  def to_json
    return to_hash.to_json
  end
end
