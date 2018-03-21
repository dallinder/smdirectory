require 'sinatra'
require 'sinatra/contrib'

require_relative 'db_persistence'

configure do
	enable :sessions
	set :session_secret, 'secret'
	set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "db_persistence.rb"
end

before do
  @storage = Database.new(logger)
end

after do
  @storage.disconnect
end

get '/' do
	@all_schools = @storage.get_all_schools

	erb :index
end

