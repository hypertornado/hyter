require 'sinatra'
require_relative "anotation.rb"

get "/" do
	redirect "/index.html"
end

get "/results" do
	Anotation.new(params['q']).get_result()
end