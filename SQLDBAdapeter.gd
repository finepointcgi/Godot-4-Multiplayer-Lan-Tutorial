extends Node
class_name SQLDBAdapter

var database


func CreateDB():
	database = SQLite.new()
	database.open_db()
	var table = {
		"id": {
			"data_type":"int", 
			"primary_key": true, 
			"not_null": true,
			"auto_increment": true
		},
		"name":{
			"data_type":"text",
			"not_null":true
		},
		"password":{
			"data_type":"text",
			"not_null":true
		},
		"elo":{
			"data_type":"int",
			"not_null":true
		}
	}
	database.create_table("users", table)
	
	var data = {
		"name" : "test",
		"password": "test",
		"elo": 100
	}
	
	database.insert_row("users", data)
