#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db 
  db_create = SQLite3::Database.new 'my_db.db'
  db_create.results_as_hash = true
  return db_create
end

configure do 
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS "Users" 
    (
      "Id" INTEGER PRIMARY KEY, 
      "user_name" TEXT, 
      "user_phone" TEXT,
      "date_time" TEXT,
      "select_teacher" TEXT,
      "color_jquery" TEXT
    )'
  db.close
end

get '/' do
  erb :index
  # erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about_us' do 
  @error = "Hi"
  erb :about_us
end

get '/appointment' do 
  erb :appointment
end

def save_in_db 
  db = get_db
  db.execute 'insert into Users (user_name, user_phone, date_time, select_teacher, color_jquery) values (?, ?, ?, ?, ?)', [@user_name, @user_phone, @date_time, @select_teacher, @color_jquery]
end

post '/appointment' do 
  @user_name = params[:user_name]
  @user_phone = params[:user_phone]
  @date_time = params[:date_time]
  @select_teacher = params[:select_teacher]
  @color_jquery = params[:color_jquery]

  validate_error = {
    user_name: "Enter name", 
    user_phone: "Enter phone", 
    date_time: "Enter date time", 
    select_teacher: "Enter teacher", 
    color_jquery: "Enter color"
  }

  validate_error.each do |key, value|
    if params[key] == ''
      @error = validate_error[key]
      return erb :appointment
    end
  end

  file_users_data = File.open("./public/users_date.txt", "a") do |f|
    f.write("Persona_draw_school: #{@user_name}, Phone: #{@user_phone}, Data_visit: #{@date_time}, Select teacher: #{@select_teacher}, Color: #{@color_jquery}\n")
    f.close
  end

  save_in_db

  erb "Your create print. Persona_draw_school: #{@user_name}, Phone: #{@user_phone}, Data_visit: #{@date_time}, Select teacher: #{@select_teacher}, Color: #{@color_jquery}"
  # erb :appointment
end

post '/contacts' do 
  @email_address = params['email_address']
  @text_email_address = params['text_email_address']

  file_email_data = File.open("./public/email_data.txt", "a") do |f|
    f.write("Email address: #{@email_address}, Text message: #{@text_email_address}\n")
    f.close
  end

  erb :contacts
end

get '/contacts' do 
  erb :contacts
end

get '/admin' do 
  # @logfile = File.read("public/email_data.txt")
  erb :admin
end

get '/admin/show' do 
  db = get_db
  @db_result = db.execute 'select * from Users order by id desc'  
  erb :show
end

get '/authorization' do 
  erb :authorization
end 

post '/authorization' do
  @niсkname = params[:niсkname]
  @user_password = params[:user_password]

  if @niсkname == "admin" && @user_password == "rokit"
    # @logfile = File.read("public/email_data.txt")
    # redirect to ('/admin')
    db = get_db
    db.execute 'select * from Users' do |date_user|
      @date_users = "Persona_draw_school: #{date_user[0]}, Phone: #{date_user[1]}, Data_visit: #{date_user[2]}, Select teacher: #{date_user[3]}, Color: #{date_user[4]}"
      # @date_users = {"user_name" => params[:user_name], "user_phone" => params[:user_phone], "date_time" => params[:date_time], "select_teacher" => params[:select_teacher], "color_jqvery" => params[:color_jqvery]}
    end
    erb :admin
  else
    erb "Sorry, bad password. Try again."
  end
end

