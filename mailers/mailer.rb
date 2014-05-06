# class Mailer < ActionMailer::Base
#   default to: "narasinga.raju50@gmail.com"

#   def notification(from_email)
#     mail(from: from_email, subject: "New notification") do |format|
#       format.text
#       format.html
#     end
#   end
# end

 
class Mailer < ActionMailer::Base
  def contact
    mail(
      :to      => "raju.narasing20@gmail.com",
      :from    => "narasinga.raju50@gmail.com",
      :subject => "Test") do |format|
        format.text
        #format.html
    end
  end

  def notify_occasion(occasion)
    @occasion = occasion
    puts "*******************************"
    puts " Notify #{ @occasion.friend.user.first_name } to his email #{ @occasion.friend.user.email }."
    opts = { to: @occasion.friend.user.email, from: "no-reply@givify.com",
             subject: "#{@occasion.friend.first_name}'s #{@occasion.type} is only 7 days away" }
    mail(opts) do |format|
      format.text
    end 
  end

end
 
