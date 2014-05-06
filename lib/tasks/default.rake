task :default do
  puts "Hello World!"
  puts "#{Gift.last.name}"
  puts "#{Friend.last.first_name}"
end

task :notify_user do 
  Occasion.all.each do |occasion|
    date = Date.new( Date.today.year, occasion.date.month, occasion.date.day )
    if( date - 7.days ) == Date.today
      occasion.notify
    end
  end
end
