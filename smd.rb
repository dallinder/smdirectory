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

# displays main page

get '/' do
	@all_schools = @storage.get_all_schools

	erb :index, layout: :layout
end

# page to add a school. displays a form.

get '/add_school' do
	erb :add_school, layout: :layout
end


def error_for_school_name(school_name)
  if !(1..50).cover? school_name.size
    "Your school name must contain between 1 and 50 characters."
  elsif @storage.get_all_schools.any? { |school| school[:name] == school_name }
    "This school is already in our database."
  end
end

# add a school to the library

post '/add_school' do
	school = params[:school_name].strip
	if error = error_for_school_name(school)
		session[:error] = error
		erb :add_school, layout: :layout
	else
		@storage.add_school(school)
		session[:success] = "#{school} has been added to the database."
		redirect "/"
	end
end


# Display one school and it's library

get '/school/:id' do
	@id = params[:id]

	@school = @storage.get_one_school(@id)
	@pieces = @storage.get_pieces(@id)

	erb :school, layout: :layout
end


def error_for_new_music(name, composer, school_id)
  if !(1..50).cover? name.size
    "You must include a name for the piece between 1 and 50 characters."
  elsif !(1..50).cover? composer.size
    "The composers name must be between 1 and 50 characters."
  elsif @storage.get_pieces(school_id).any? { |music| music[:title].downcase == name.downcase }
    "This piece is already in the database."
  end
end


# Display add a new piece form

get '/school/:id/add_piece' do
	@id = params[:id]
	@school = @storage.get_one_school(@id)

	erb :add_piece, layout: :layout
end

post '/school/:id/add_piece' do
	@id = params[:id]
	title = params[:title].strip
	composer = params[:composer].strip
	@school = @storage.get_one_school(@id)
	if error = error_for_new_music(title, composer, @id.to_i)
		session[:error] = error
		erb :add_piece, layout: :layout
	else
		@storage.add_piece(title, composer, @id)
		session[:success] = "Added #{title} to the database!"
		redirect "/school/#{@id}"
	end

end

