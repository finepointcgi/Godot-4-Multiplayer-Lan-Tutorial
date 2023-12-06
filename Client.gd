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
var _peer = WebSocketMultiplayerPeer.new()
var peerid = 0
var lobbyValue
var rtc_mp: WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var host
var index 
var checkInTimer : Timer

var player_elo = 1500

func _ready():
	multiplayer.connected_to_server.connect(self._mp_server_connected)
	multiplayer.connection_failed.connect(self._mp_server_disconnect)
	multiplayer.server_disconnected.connect(self._mp_server_disconnect)
	multiplayer.peer_connected.connect(self._mp_peer_connected)
	multiplayer.peer_disconnected.connect(self._mp_peer_disconnected)
	pass
	#get_tree().set_multiplayer_authority(_peer.get_unique_id())

func _process(delta):
	_peer.poll()
	rtc_mp.poll()
	var t : String
	for i in rtc_mp.get_peers():
		t = t + "\n" + str(i)
	#$RichTextLabel.text = t
	if _peer.get_available_packet_count() > 0:
		var packet = _peer.get_packet()
		if packet != null:
			# Convert the PoolByteArray to a String for easier parsing
			var packet_string = packet.get_string_from_utf8()
			print("Received data from server: ", packet_string)
			var data = JSON.parse_string(packet_string)
			if data != null:
				if data.message == Message.id:
					peerid = data.id
					#printToConsole("got id: " + str(peerid))
					_connected(peerid, true)
					$Label3.text = "Name: " + str(data.id)
					
				
				if data.message == Message.lobby:
					lobbyValue = data.lobbyValue
					host = data.host
					if(host == peerid):
						$Label2.text = "Host: true"
					
					GameManager.Players = JSON.parse_string(data.lobby)
	#				for i in GameManager.Players:
	#					printToConsole("####### Connecting Peer " + str(data.id))
	#					_create_peer(data.id)
					#GameManager.Players[data.player.id] = data.player
					printToConsole("lobby id is: " + lobbyValue)
				
				if data.message == Message.userConnected:
					#GameManager.Players[data.player.id] = data.player
					printToConsole("####### Connecting Peer " + str(data.id))
					#_create_peer(data.id)
					pass
										
# connects the users together
func _connected(id, use_mesh):
	printToConsole("Connected %d, mesh: %s" % [id, use_mesh])
	
func _on_button_4_button_down():
	#_peer.create_client("ws://204.48.28.159:8915")
	_peer.create_client("ws://127.0.0.1:8915")
	##printToConsole("started client")
	checkInTimer = Timer.new()
	add_child(checkInTimer)
	checkInTimer.timeout.connect(checkIn)
	
	#checkInTimer.start(5)
	pass # Replace with function body.

func _on_button_5_button_down():
	
	var message = {
		"peer" : peerid,
		"message" : Message.join,
		"lobbyValue" : $LobbyValue.text
	}
	lobbyValue = $LobbyValue.text
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	##printToConsole("connecting... ")
	_peer.put_packet(message_bytes)
	
	pass # Replace with function body.

func checkIn():
	var message = {
		"id" : peerid,
		"message" : Message.CheckIn,
	}
	
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	##printToConsole("connecting... ")
	_peer.put_packet(message_bytes)

@rpc("any_peer", "call_local")
func ping(argument):
	printToConsole("[Multiplayer] Ping from peer %d: arg: %s" % [multiplayer.get_remote_sender_id(), argument])
	#var scene = load("res://testScene.tscn").instantiate()
	#get_tree().root.add_child(scene)
	#$TextEdit.text = $TextEdit.text + "/n" + str(argument)
	pass

func _on_button_7_button_down():
	ping.rpc(randf())
	pass # Replace with function body.

func _mp_server_connected():
	##printToConsole("[Multiplayer] Server connected (I am %d)" % rtc_mp.get_unique_id())
	pass

func _mp_server_disconnect():
	##printToConsole("[Multiplayer] Server disconnected (I am %d)" % rtc_mp.get_unique_id())
	pass

func _mp_peer_connected(id: int):
	printToConsole("[Multiplayer] Peer %d connected" % id)
	pass

func _mp_peer_disconnected(id: int):
	##printToConsole("[Multiplayer] Peer %d disconnected" % id)
	pass

func printToConsole(s : String):
	$TextEdit.text = $TextEdit.text + "\n " + s
	#print(s)

func _on_button_2_button_down():
	var s = rtc_mp.get_peers()
	printToConsole(str(rtc_mp.get_peers()))
	pass # Replace with function body.

func _on_button_button_down():
	
	pass # Replace with function body.

func _on_button_3_button_down():
	var message = {
		"id" : peerid,
		"message" : Message.matchmake,
		"player" : {
			"id" : peerid,
			"elo" : int($Control/TextEdit.text)
			
		}
	}
	
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	printToConsole("registering to elo")
	_peer.put_packet(message_bytes)
	pass # Replace with function body.
