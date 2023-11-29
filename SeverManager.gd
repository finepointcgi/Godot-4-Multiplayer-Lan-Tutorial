extends Node

enum Message {
	join,
	id, 
	connect,
	disconnect,
	lobby,
	CANDIDATE,
	OFFER,
	ANSWER,
	userConnected,
	lobbyInfo,
	CheckIn,
	matchmake
}
const CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var _peer = WebSocketMultiplayerPeer.new()

var users : Dictionary = {}

var lobbies : Dictionary = {}

var serverStarted : bool = false

var  matchmakeUsers = {

}

var timeoutinSeconds = 10
var hostedPort = 8915

func _ready():
	if "--server" in OS.get_cmdline_args():
		#print("hosting on " + str(hostedPort))
		_peer.create_server(hostedPort)
		serverStarted = true
	_peer.connect("peer_connected", peerConnected)
	_peer.connect("peer_disconnected", peerDisconnected)
	pass
	
func _process(delta):
	if serverStarted:
		_peer.poll()
		for i in users:
			if("lastConnected" in users[i] ):
				##print( Time.get_unix_time_from_system() - float(users[i].lastConnected))
				if float(Time.get_unix_time_from_system() - users[i].lastConnected) > timeoutinSeconds:
					disconnectUser(i)

		for user in matchmakeUsers:
			pass
		if _peer.get_available_packet_count() > 0:
			var packet = _peer.get_packet()
			if packet != null:
				
				
				# Convert the PoolByteArray to a String for easier parsing
				#var packet_string = packet.get_string_from_utf8()
				##print("Received data: ", packet_string)
				var data = JSON.parse_string(packet.get_string_from_utf8())
				
				if data.message == Message.disconnect:
					peerDisconnected(data.id) 
				
				if data.message == Message.join:
					JoinLobby(data.peer, data.lobbyValue)
					return
				if data.message == Message.matchmake:
					add_player_to_queue(data.player.id, data.player.elo)
					return
				if data.message == Message.CheckIn:
					users[int(data.id)].lastConnected = Time.get_unix_time_from_system()
		
		match_players()

func add_player_to_queue(player_id, player_elo):
	matchmakeUsers[player_id] = {
		"id": player_id,
		"elo": player_elo
		}
	
	#match_players()  # Try to match players

func match_players():
	# Logic to match players based on ELO rating
	# For simplicity, this is a basic example
	for id in matchmakeUsers:
		for lobby in lobbies:
			if lobby.IsElegableForMatch(id):
				lobby.add_player_to_lobby(id)
		
func is_eligible_for_match(id, opponent_id):
	if id == opponent_id:
		return false  # Can't match with oneself
	var elo_difference = abs(matchmakeUsers[id] - matchmakeUsers[opponent_id])
	return elo_difference < 100  # Example threshold

func start_match(id1, id2):
	print("Match started between %s and %s" % [id1, id2])
	# Initialize match logic here

func update_elo_ratings(player1_id, player2_id, winner_id):
	# Update ELO ratings based on match outcome				
	pass
	
func JoinLobby(peer, id :String):
	if id == "":
		id = generate_random_string()
		lobbies[id] = Lobby.new(peer)
		#print(id)
	
	var player = lobbies[id].AddPlayer(peer)
	for p in lobbies[id].players:
		#print("sending new user info to peer")
		#print(lobbies[id].players[p])
		var data = {
			"message" : Message.userConnected,
			"id" : peer
		}
		sendMessageToPeer(p, data)
		
		#print("sending other player info to new user")
		var data2 = {
			"message" : Message.userConnected,
			"id" : p
		}
		sendMessageToPeer(peer, data2)
		
		var data3 = {
			"message" : Message.lobbyInfo,
			"lobby" : JSON.stringify(lobbies[id].players)
		}
		
		sendMessageToPeer(p, data3)
	
	##print("peer " + str(peer) + " joined lobby " + str(id))
	##print("lobbies look like " + str(lobbies))
	var data = {
		"message": Message.lobby,
		"lobbyValue": id,
		"host": lobbies[id].hostid,
		"player" : player,
		"lobby" : JSON.stringify(lobbies[id].players)
	}
	#print(data)

	sendMessageToPeer(peer, data)
		
func generate_random_string():
	var result = ""
	for _i in range(32):
		var random_index = randi() % CHARACTERS.length()
		result += CHARACTERS[random_index]
	return result


func disconnectUser(id):
	if users.has(id):
		users.erase(id)
	_peer.disconnect_peer(id)
		

func peerConnected(id):
	#print("connected" + str(id))
	users[id] = {
		"id" : id,
		"inGameId" : 0,
		"lastConnected" : Time.get_unix_time_from_system()
	}
	
	var data = {
		"message" : Message.id,
		"id" : id
	}
	sendMessageToPeer(id, data)

func peerDisconnected(id):
	#print("disconnected" + str(id))
	disconnectUser(id)
	
func _on_button_button_down():
	_peer.create_server(hostedPort)
	#print("started server")
	serverStarted = true
	pass # Replace with function body.

func sendMessageToPeer(id, packet):
	var peers = [id]
	sendMessageToPeers(peers, packet)

func sendMessageToPeers(ids, packet):
	var message_bytes = JSON.stringify(packet).to_utf8_buffer()
	for id in ids:
		_peer.get_peer(id).put_packet(message_bytes)
		pass
	

func _on_button_5_button_down():
	var message = "Hello, server!"
	var message_bytes = message.to_utf8_buffer()
	_peer.put_packet(message_bytes)
	#_peer.get_peer(users[0]).put_packet(message_bytes)
	pass # Replace with function body.
	


func _on_button_6_button_down():
	pass # Replace with function body.
