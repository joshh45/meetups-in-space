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

post '/newmeetup' do
  @name = params[:article]
  @info = Meetup.create(name: @name, description: "hi", location: "malden", creator_id: "here")

  redirect '/meetups'
end

get '/newmeetup' do
  erb :'meetups/newmeetup'
end

get '/show' do
  erb :'meetups/show'
end
