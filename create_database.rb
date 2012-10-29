
require 'sqlite3'

db = SQLite3::Database.new "databaze.db"

rows = db.execute <<-SQL
  create table user (
  id INTEGER PRIMARY KEY UNIQUE,
   username varchar(100),
   password varchar(100)
  );
SQL

rows = db.execute <<-SQL
  create table annotation (
  id INTEGER PRIMARY KEY UNIQUE,
   username varchar(100),
   sentence text,
   data text,
   time integer
  );
SQL


db.execute("INSERT INTO user (username, password) 
            VALUES (?, ?)", ["hypertornado", "ondra85"])