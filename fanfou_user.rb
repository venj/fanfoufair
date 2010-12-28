class FanfouUser
  attr_reader :name, :uid, :profile_image_url
  def initialize(dict)
    @name = dict["screen_name"]
    @uid = dict["id"]
    @profile_image_url = dict["profile_image_url"]
  end
  
  def ==(b)
    @uid == b.uid
  end
end