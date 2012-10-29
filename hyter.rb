require 'sinatra'
require_relative "anotation.rb"
require "sqlite3"
require "json"
require "sinatra/reloader" if development?

enable :sessions

DB_NAME = "databaze.db"
ADMINS = ['hypertornado']

get "/" do
	if session['username']
		redirect "/annotation"
	else
		redirect "/login.html"
	end
end

post "/remove_result" do
	db = SQLite3::Database.new DB_NAME
	db.execute("delete from annotation where username=? and sentence=?", session['username'], params['sentence']).inspect
	redirect "/"
end

get "/result/:id" do
	db = SQLite3::Database.new DB_NAME
	db.execute("select * from annotation where username=? and id=?", session['username'], params[:id]).first.to_json
end

get "/results" do
	unless session['username']
		return {error: "authentication"}.to_json
	end

	data = JSON.parse(params['q'])

	puts data.inspect

	db = SQLite3::Database.new DB_NAME
	db.execute("INSERT INTO annotation (username, sentence, data, time) VALUES (?, ?, ?, ?)", session['username'], data['words'].join(" "), data.to_json, Time.now.to_i)

	result = Anotation.new(params['q']).get_result()
	return result
end

get "/annotation" do
	redirect "/" unless session['username']
	@user = session['username']

	db = SQLite3::Database.new DB_NAME

	@annotations = db.execute("select max(id), username, sentence, time from annotation where username=? group by sentence", session['username'])
	erb :annotation
end

post "/authenticate" do
	session['username'] = nil
	db = SQLite3::Database.new DB_NAME
	result = db.execute("select * from user where username=? and password=?", [params['username'], params['password']])
	puts result.inspect
	if result.size == 1
		session['username'] = result[0][1]
		redirect "/"
	else
		redirect "/login.html"
	end
end

post "/add_user" do
	redirect "/login.html" unless ADMINS.include? session['username']
	db = SQLite3::Database.new DB_NAME
	db.execute("INSERT INTO user (username, password) VALUES (?, ?)", [params['username'], params['password']])
	redirect "/admin"
end


get "/admin" do
	redirect "/login.html" unless ADMINS.include? session['username']
	db = SQLite3::Database.new DB_NAME
	@users = db.execute("select * from user")
	erb :admin
end


get "/logout" do
	session['username'] = nil
	redirect "/"
end

get "/session" do
	session['username']
end