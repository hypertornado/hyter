require 'sinatra'
require_relative "anotation.rb"
require "sqlite3"
require "json"
#require "sinatra/reloader"

enable :sessions, :logging
set :logging, true

DB_NAME = "databaze.db"
ADMINS = ['hypertornado', 'bojar', 'zeman']

get "/" do
	if session['username']
		redirect "/annotation"
	else
		redirect "/login.html"
	end
end

post "/remove_result" do
	db = SQLite3::Database.new DB_NAME
	db.execute("update annotation set deleted='1' where username=? and sentence=?", session['username'], params['sentence'])
	#db.execute("delete from annotation where username=? and sentence=?", session['username'], params['sentence']).inspect
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

	result = Anotation.new(params['q']).get_result()
	data['result'] = result

	db = SQLite3::Database.new DB_NAME
	db.execute("INSERT INTO annotation (username, sentence, data, time) VALUES (?, ?, ?, ?)", session['username'], data['words'].join(" "), data.to_json, Time.now.to_i)

	return result
end

get "/annotation" do
	redirect "/" unless session['username']
	@user = session['username']

	db = SQLite3::Database.new DB_NAME

	@annotations = db.execute("select max(id), username, sentence, time, deleted from annotation where username=? group by sentence", session['username'])
	erb :annotation
end

post "/authenticate" do
	session['username'] = nil
	db = SQLite3::Database.new DB_NAME
	result = db.execute("select * from user where username=? and password=?", [params['username'], params['password']])
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

	result = db.execute("select * from user where username=?", [params['username']])
	if result.size > 0
		redirect "/admin"
	end
	db.execute("INSERT INTO user (username, password) VALUES (?, ?)", [params['username'], params['password']])
	redirect "/admin"
end

get "/export_times" do
	redirect "/login.html" unless ADMINS.include? session['username']
	db = SQLite3::Database.new DB_NAME
	@annotations = db.execute("select id, username, time, sentence, deleted from annotation order by username, time")
	ret = ""
	@annotations.each do |a|
		ret += "#{a[0]}\t#{a[1]}\t#{a[2]}\t#{a[4]}\t#{a[3]}\n"
	end
	ret
end

get "/export_prolog/:id" do
	redirect "/login.html" unless ADMINS.include? session['username']
	db = SQLite3::Database.new DB_NAME
	@annotations = db.execute("select id, username, sentence, time, deleted, data from annotation where id=?", @params['id'])

	anotation = Anotation.new(@annotations.first[5])

	return anotation.construct_prolog_string(true)
end

get "/admin" do
	redirect "/login.html" unless ADMINS.include? session['username']
	@db = SQLite3::Database.new DB_NAME
	@users = @db.execute("select * from user")
	erb :admin
end


get "/logout" do
	session['username'] = nil
	redirect "/"
end

get "/sentence/:user/:sentence" do

	redirect "/login.html" unless ADMINS.include? session['username']

	db = SQLite3::Database.new DB_NAME

	@annotations = db.execute("select id, username, sentence, time, deleted, data from annotation where username=? and sentence=?", @params['user'], @params['sentence'])
	
	erb :sentence
end

get "/session" do
	session['username']
end

post "/create_translation" do

	redirect "/login.html" unless ADMINS.include? session['username']

	db = SQLite3::Database.new DB_NAME

	words = params['text'].strip.split(/[ \t]+/)

	data = {words: words, reference: params['reference']}

	db.execute("INSERT INTO annotation (username, sentence, data, time) VALUES (?, ?, ?, ?)", params['username'], words.join(" "), data.to_json, Time.now.to_i)

	redirect "/admin"
end



