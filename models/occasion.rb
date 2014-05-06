class Occasion
  include Mongoid::Document
  field :name, type: String
  field :type, type: String
  field :date, type: DateTime

  belongs_to :friend
  has_many :gifts
  has_many :recommendations

  def <=>(o)
    return self.relative_date <=>
      o.relative_date
  end

  def from_params(params)
    return nil unless params[:name] and params[:type] and params[:date]

    self.name = params[:name]
    self.type = params[:type]
    self.date = params[:date]
    return self.save
  end

  def update_from_params(params)
    self.name = params[:name] if params[:name]
    self.type = params[:type] if params[:type]
    self.date = params[:date] if params[:date]
    return self.save
  end

  def relative_date
    return self.date ? Time.parse(self.date.to_time.strftime("%m/%d")) : Time.now
  end

  def refresh_recommendations
    if @friend.facebook_id
      recommendations = Hunch.new(settings.hunch_token).recommendations(
        @friend.facebook_id, 'birthday')["recommendations"].each
    else
      recommendations = []
    end
    recommendations.each do |recommendation|
      next unless recommendation["name"] and
        recommendation["url"] and
        recommendation["image_url"]
      r = Recommendation.new
      self.recommendations.push(r)
      r.from_hunch(recommendation)
      self.save if r
    end
  end

  def cached_recommendations
    if self.recommendations.length > 0
      return self.recommendations
    end
    refresh_recommendations
    return self.recommendations
  end

  def to_hash
    {
      :id => self.id,
      :name => self.name,
      :type => self.type,
      :date => self.date
    }
  end

  def to_json
    return to_hash.to_json
  end

  def notify
    Mailer.notify_occasion(self).deliver
  end
end
