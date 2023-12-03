extends RefCounted
class_name Lobby

var hostid : int
var players: Dictionary = {}
var game : Game
var host : int = -1
var players_in_lobby = []
var lobby_timer_started = false
var lobby_wait_end_time_timer_started = false
var lobby_countdown = 10  # 60 seconds countdown
var lobby_wait_end_time = 60
var minimum_players_to_start = 8
var maxPlayers = 8
var lobbyElo
var closed = false

func _init(_id):
	hostid = _id
	game = Game.new()

func _process(delta):
	if lobby_timer_started and players_in_lobby.size() >= minimum_players_to_start:
		lobby_countdown -= delta

		if lobby_countdown <= 0:
			start_game()
			update_lobby_ui(lobby_countdown)
	
	if lobby_wait_end_time_timer_started and players_in_lobby.size() == maxPlayers:
		lobby_wait_end_time -= delta

		if lobby_wait_end_time <= 0:
			start_game()
			update_lobby_ui(lobby_wait_end_time)

func add_player_to_lobby(player):
	players[player.id] = {
		"name" : "",
		"id": player.id,
		"index": players.size() + 1,
		"elo" : player.elo
	}
	
	if players_in_lobby.size() == minimum_players_to_start and !lobby_timer_started:
		lobby_timer_started = true

	if players_in_lobby.size() > 1:
		lobby_wait_end_time_timer_started = true
	lobbyElo = (lobbyElo + players[player.id].elo) / 2
	return players[player.id]

func start_game():
	# Logic to start the game with current players in the lobby
	pass
	
func update_lobby_ui(time_left):
	# Update the lobby UI with the remaining time
	pass

func IsElegableForMatch(player):
	for i in players:
		if i.id == player.id:
			return false
	if abs(player.elo - lobbyElo) < 100:
		return false	
	return true
