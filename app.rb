require 'sinatra'
require "pg"
require_relative 'config/application'
require 'pry'

set :bind, '0.0.0.0'  # bind to all interfaces

helpers do
  def current_user
    if @current_user.nil? && session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      session[:user_id] = nil unless @current_user
    end
    @current_user
  end

  def signed_in?
    current_user.present?
  end

  def authenticate!
    unless signed_in?
      flash[:notice] = "Please sign in if you want to create a new event!"
      redirect '/meetups'
    end
  end



end


get '/' do
  redirect '/meetups'
end

get '/auth/github/callback' do
  user = User.find_or_create_from_omniauth(env['omniauth.auth'])
  session[:user_id] = user.id
  flash[:notice] = "You're now signed in as #{user.username}!"
  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/meetups' do
  @meetupobject = Meetup.all
  erb :'meetups/index'
end


get '/meetups/:id' do
  @id = params[:id]
  @data = Meetup.find(@id)
  @poster = current_user.username
  @avatar_url = current_user.avatar_url
  erb :'meetups/show'
end

post '/newmeetup' do

    authenticate!

    @name = params[:name]
    @description = params[:description]
    @location = params[:location]
    @creator = params[:creator]

    @info = Meetup.create(name: @name, description: @description, location: @location, creator_id: @creator)

    if @info.name.empty?
      flash[:notice] = "Missing Name"
      redirect '/newmeetup'

    elsif @info.description.empty?
      flash[:notice] = "Missing Description"
      redirect '/newmeetup'

    elsif @info.location.empty?
      flash[:notice] = "Missing Location"
      redirect '/newmeetup'

    else

      flash[:notice] = "You have successfully created a new meetup called #{@name}!"
      redirect '/meetups'

  end
end

get '/newmeetup' do
  erb :'meetups/newmeetup'
end

get '/show' do
  erb :'meetups/show'
end
