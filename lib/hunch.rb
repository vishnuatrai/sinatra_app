class Hunch
  include HTTParty
  base_uri 'api.hunch.com'

  def initialize(token)
    @token = token
  end

  def recommendations(fb_id, query)
    res = self.class.get(
        "/api/v1/get-recommendations/?user_id=fb_#{fb_id}&sites=hn,amz&limit=9")
    JSON.parse(res.body)
  end
end