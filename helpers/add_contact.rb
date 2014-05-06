class AddContact
  def self.relationship_list
    {:mother => "Mother", :father => "Father", :brother => "Brother",
     :sister => "Sister", :son => "Son", :daughter => "Daughter",
     :mother_in_law => "Mother-in-Law", :father_in_law => "Father-in-Law",
     :brother_in_law => "Brother-in-Law", :sister_in_law => "Sister-in-Law",
     :grandmother => "Grandmother", :grandfather => "Grandfather",
     :grandson => "Grandson", :granddaughter => "Granddaughter",
     :cousin => "Cousin", :aunt => "Aunt",
     :uncle => "Uncle", :friend => "Friend"}
  end

  def self.days
    1..31
  end

  def self.months
    1..12
  end

  def self.years
    1970..(Time.now.year)
  end

  def self.sort_usernames(friends)
    friends.compact.sort! { |a,b| a.name.downcase <=> b.name.downcase }
  end
end