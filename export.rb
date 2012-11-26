
DB_NAME = "databaze.db"
FILE_NAME = "zadani.txt"
require "sqlite3"
require "json"

f = File.open(FILE_NAME)
lines = f.readlines


lines.map! {|l| l.chomp.split("\t")}

def create_anotation(aut, line)
	password = "heslo#{aut}"
	author = "anot-#{aut}"

	db = SQLite3::Database.new DB_NAME

	result = db.execute("select * from user where username=?", [author])
	if result.size == 0
		db.execute("INSERT INTO user (username, password) VALUES (?, ?)", [author, password])
	end

	sentence = line[3]
	sentence = line[4] if aut == "JB"

	puts author
	reference = line[5,1000].join("<br>")
	puts sentence

	words = sentence.strip.split(/[ \t]+/)

	data = {words: words, reference: reference}

	db.execute("INSERT INTO annotation (username, sentence, data, time) VALUES (?, ?, ?, ?)", author, words.join(" "), data.to_json, Time.now.to_i)


end

lines.each do |line|
	create_anotation(line[0], line)
	create_anotation(line[1], line)
end