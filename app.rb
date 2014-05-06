require 'rubygems'
require 'bundler/setup'
Bundler.require
require 'mongoid'

configure do
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "static") }
  use Rack::Session::Cookie, :key => 'rack.session',
                             :secret => 'change_me'
  Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))

  # Facebook config
  if settings.development?
    set :mandrill_user_name, 'vishnu.atrai@gmail.com'
    set :mandrill_password, '0qG5h12L9DOoOIqLE-_CIA'
    set :mandrill_api_key, '0qG5h12L9DOoOIqLE-_CIA'
    set :facebook_app_id, 142461909979
    set :facebook_secret, "3ceca314e34f039343949ac1c8d0fe07"
    set :facebook_site_url, "http://localhost:4567/"
  else
    set :mandrill_user_name, 'vishnu.atrai@gmail.com'
    set :mandrill_password, '0qG5h12L9DOoOIqLE-_CIA'
    set :mandrill_api_key, '0qG5h12L9DOoOIqLE-_CIA'
    set :facebook_app_id, 412195022205133
    set :facebook_secret, "c6669cfccef7e9604ea0fb02bbbb020c"
    set :facebook_site_url, "http://beta.givify.co/"
  end

  # Hunch config
  set :hunch_token, "72fe9a13466cfbf8f1ceea004c4139a78fff3520"
  # Action mailer config
  set :root,    File.dirname(__FILE__)
  set :views,   File.join(Sinatra::Application.root, 'views')
  set :html,    { :format => :html }
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      :address              => "smtp.mandrillapp.com",
      :port                 => 587,
      :domain               => "givify.com",
      :user_name            => settings.mandrill_user_name,
      :password             => settings.mandrill_password,
      :authentication       => "plain",
      :enable_starttls_auto => true
    }
    ActionMailer::Base.view_paths = File.expand_path('../views/', __FILE__)

    MandrillMailer.config.api_key = settings.mandrill_api_key
end


# models
require_relative 'models/friend.rb'
require_relative 'models/gift.rb'
require_relative 'models/occasion.rb'
require_relative 'models/recommendation.rb'
require_relative 'models/user.rb'

# libraries
require_relative 'lib/facebook.rb'
require_relative 'lib/hunch.rb'

# helpers
require_relative 'helpers/add_contact'
require_relative 'mailers/mailer.rb'


require 'action_view'

helpers do
  def session_user
    if (session[:user_id])
      return User.find(session[:user_id])
    end
    nil
  end

  def username
    session_user ? session_user.name : nil
  end

  def logged_in?
    session[:user_id] ? true : false
  end

  include ActionView::Helpers::DateHelper
end

get '/' do
  if logged_in?
    redirect to '/home'
  else
    erb :index, :layout => false
  end
end



get '/add_friends' do
  @friends = graph.get_connections('me', 'friends')
  @family = graph.get_connections('me', 'family')
  erb :add_friends
end

post '/add_friend' do
  friend = Friend.find_by(facebook_id: params[:facebook_id], user_id: session[:user_id])
  if friend
    puts "friend already added. (#{params[:facebook_id]})"
    halt 200
  end

  friend_params = graph.get_object(params[:facebook_id], fields: 'birthday,first_name,last_name,email')
  facebook_id = friend_params.delete("id")
  friend_params["facebook_id"] = facebook_id
  friend_params.symbolize_keys!
  friend = Friend.new
  u = session_user
  u.friends.push(friend)
  halt 400 unless friend.from_params(friend_params)
  halt 400 unless u.save
  friend.to_json
end

post '/add_contact' do
  friend = Friend.new
  u = session_user
  u.friends.push(friend)
  halt 400 unless friend.update_from_params(params)
  halt 400 unless u.save
  redirect to '/home'
end

get '/occasions' do
  @occasions = session_user.upcoming_occasions
  @occasions.sort!
  erb :occasions
end

get '/occasions/:occasion_id' do
  @occasion = Occasion.find(params[:occasion_id])
  halt 404 if not @occasion
  @gifts = @occasion.gifts
  erb :_gift_queue, :layout => false, :locals => {:occasion => @occasion}
end

get '/users/:user_id' do
  @friend = Friend.find(params[:user_id])
  halt 404 if not @friend
  @occasion = @friend.occasions.compact.try(:first)
  p "---------------------"
  p @occasion.gifts.order_by([[ :row_order, :asc ]])
  #p @occasion.gifts.find({},{:row_order => 1,:_id => 0}).sort({:row_order => 1})
  #db.mycol.find({},{"title":1,_id:0}).sort({"title":-1})
  p "-------------------------"
  

  erb :_gift_queue, :layout => false, :locals => {:occasion => @occasion}
end


get '/occasions/:occasion_id/queued' do
  @occasion = Occasion.find(params[:occasion_id])
  halt 404 if not @occasion
  @gifts = @occasion.gifts
  erb :_queued_gifts, :layout => false, :locals => {:occasion => @occasion}
end

get '/occasions/:occasion_id/gifts/new' do
  @occasion = Occasion.find(params[:occasion_id])
  halt 404 if not @occasion
  erb :_new_gift, :layout => false, :locals => {:occasion => @occasion}
end

post '/occasions/:occasion_id/gifts' do
  @occasion = Occasion.find(params[:occasion_id])
  halt 404 if not @occasion
  puts params.inspect
  @gift = Gift.new(name: params[:product],
                   brand: params[:brand],
                   url: params[:url],
                   description: params[:description],
                   occasion_id: @occasion.id)
  success = @gift.save
  {success: success, id: @gift.id}.to_json
end

post '/occasions/:occasion_id/recommend/:recommend_id/create' do
  @occasion = Occasion.find(params[:occasion_id])
  halt 404 if not @occasion
  @recommendation = Recommendation.find(params[:recommend_id])
  halt 404 if not @recommendation
  @recommendation = @recommendation.to_hash
  p "---------"
  puts @recommendation.inspect
  @gift = Gift.new(name: @recommendation[:name],
                   brand: @recommendation[:source],
                   url: @recommendation[:url],
                   image_url: @recommendation[:image_url],
                   description: @recommendation[:description],
                   occasion_id: @occasion.id)
  success = @gift.save
  {success: success, id: @gift.id}.to_json
end

get '/gifts/:gift_id/edit' do
  @gift = Gift.find(params[:gift_id])
  halt 404 if not @gift
  erb :_edit_gift, :layout => false, :locals => {:occasion => @occasion}
end

post '/gifts/:gift_id/update' do
  @gift = Gift.find(params[:gift_id])
  halt 404 if not @gift
  puts params.inspect
  begin
  @gift.update_attributes!(name: params[:product],
                   brand: params[:brand],
                   url: params[:url],
                   description: params[:description])
  rescue
    halt 404
    return
  end
  {success: true, id: @gift.id}.to_json
end

get '/gifts/:gift_id/delete' do
  gift = Gift.find(params[:gift_id])
  gift.destroy if !gift.blank?
end

get '/occasions/:occasion_id/recommended' do
  @occasion = Occasion.find(params[:occasion_id])
  @friend = @occasion.friend
  halt 404 if not @friend
  @gifts = Hunch.new(settings.hunch_token).recommendations(
      @friend.facebook_id, 'birthday')
  erb :_recommended_gifts, :layout => false, :locals => {:occasion => @occasion}
end

get '/recommendations/:recommendation_id' do
  @recommendation = Recommendation.find(params[:recommendation_id])
  halt 404 if not @recommendation
  erb :_gift, :layout => false, :locals => {:recommendation => @recommendation, :recommended => true}
end

get '/gifts/:gift_id' do
  @gift = Gift.find(params[:gift_id])

  halt 404 if not @gift
  erb :_gift, :layout => false, :locals => {:recommendation => @gift, :recommended => false}
end

get '/gifts' do
  @gifts = Hunch.new(settings.hunch_token).recommendations(
      session_user.facebook_id, 'birthday')
  erb :gifts
end

get '/gifts/:facebook_id' do
  @friend = Friend.find_by(facebook_id: params[:facebook_id], user_id: session[:user_id])
  halt 404 if not @friend
  @gifts = Hunch.new(settings.hunch_token).recommendations(
      @friend.facebook_id, 'birthday')
  erb :gifts
end

get "/edit_user/:user_id" do
  @user = Friend.find(params[:user_id])
  halt 404 if not @user
  @occasions = @user.occasions
  erb :_edit_contact, :layout => false
end

post "/update_contact/:user_id" do
  @user = Friend.find(params[:user_id])
  halt 404 if not @user
  occasions = params["occasions"]
  @user.occasions.delete_all

  if not params["first_name"].strip.blank?
    full_name = params["first_name"].split(' ')
    first_name = full_name[0]
    full_name.shift
    last_name = full_name.join(" ")
    @user.first_name = first_name
    @user.last_name = last_name
    @user.save
  end

  occasions.each do |key, occasion|
    if !occasion["name"].blank?  && !occasion["date"].blank?
      new_ocacasion = Occasion.new(name: occasion["name"].downcase,
                  type: occasion["name"],
                  friend_id: params[:user_id],
                  date: occasion["date"].to_date)
      new_ocacasion.save
    end
  
    @occasions = @user.occasions
    redirect to '/home'
 end
end

get '/delete_contact/:user_id' do
  @user = Friend.find(params[:user_id])
  halt 404 if not @user
  @user.occasions.delete_all
  @user.delete
  redirect to '/home'
end

get '/home' do
  @user = session_user
  @occasions = session_user.upcoming_occasions
  @occasions.sort!
  erb :home
end

get '/me/more' do
  {
    :user_id => session[:user_id],
    :friends => session_user.friends.map {|f| f.to_hash}
  }.to_json
end

 post '/gifts/sort' do
   params[:gift].each_with_index do |gift_id, i|
    @gift = Gift.find(gift_id)
    @gift.row_order = i
    @gift.save
    end
    {:status => "success"}.to_json
 end

 post '/recommendations/sort' do
   params[:recommendation].each_with_index do |recommendation_id, i|
    @recommendation = Recommendation.find(recommendation_id)
    @recommendation.row_order = i
    @recommendation.save
    end
    {:status => "success"}.to_json
 end


  
get '/mail' do
  email = Mailer.contact
  email.deliver
end
