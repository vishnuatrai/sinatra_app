helpers do
  def graph
    if session[:user_id] and session[:access_token]
      return Koala::Facebook::API.new(session[:access_token])
    end
    nil
  end
end

get '/login' do
  session['oauth'] = Koala::Facebook::OAuth.new(
    '142461909979',
    '3ceca314e34f039343949ac1c8d0fe07',
    settings.facebook_site_url + 'callback'
  )
  redirect session['oauth'].url_for_oauth_code( permissions: 'email' )
  
end

get '/logout' do
  session.clear
  erb "<div class='alert alert-message'>Logged out</div>"
        redirect '/'
end

get '/callback' do
  session[:access_token] = session['oauth'].get_access_token(params[:code])
  graph_ = Koala::Facebook::API.new(session[:access_token])
  user = User.find_by(facebook_id: graph_.get_object('me')['id'])
  if not user
    user = User.new
    user.email = graph_.get_object('me')['email']
    user.first_name = graph_.get_object('me')['first_name']
    user.last_name = graph_.get_object('me')['last_name']
    user.facebook_token = session[:access_token]
    user.facebook_id = graph_.get_object('me')['id']
    user.save
  end
  user.facebook_token = session[:access_token]
  user.save
  session[:user_id] = user.id

  if user.friends.size == 0
    redirect '/add_friends'
  else
    redirect '/home'
  end
end

get '/me' do
  return graph.get_object('me').to_json
end
