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
var initial_lobby_countdown = 10
var minimum_players_to_start = 2
var maxPlayers = 8
var lobbyElo = 100
var closed = false

func _init(_id):
	hostid = _id
	game = Game.new()

func process(delta):
	# Check if there are enough players to start the countdown
	if players_in_lobby.size() >= minimum_players_to_start:
		# Start or continue the countdown
		if !lobby_timer_started:
			lobby_timer_started = true
			lobby_countdown = lobby_wait_end_time  # Set this to your initial countdown time

		lobby_countdown -= delta

		# Update the UI every frame
		update_lobby_ui(lobby_countdown)
		
		# Check if the countdown has finished
		if lobby_countdown <= 0:
			start_game()
			lobby_timer_started = false  # Stop the countdown

	# Additional condition for max players (if needed)
	elif players_in_lobby.size() == maxPlayers:
		# Similar logic can be applied here if you have specific actions for max players
		if !lobby_timer_started:
			lobby_timer_started = true
			lobby_countdown = initial_lobby_countdown  # Set this to your initial countdown time
			
		lobby_countdown -= delta
		
		# Update the UI every frame
		update_lobby_ui(lobby_countdown)
		
		# Check if the countdown has finished
		if lobby_countdown <= 0:
			start_game()
			lobby_timer_started = false  # Stop the countdown
	
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
	lobbyElo = (lobbyElo + player.elo) / 2
	lobby_wait_end_time = 60
	return players[player.id]

func start_game():
	# Logic to start the game with current players in the lobby
	pass
	
func update_lobby_ui(time_left):
	# Update the lobby UI with the remaining time
	pass

func IsElegableForMatch(player):
	print(player.elo)
	print(lobbyElo)
	for i in players:
		if players[i].id == player.id:
			return false
	if abs(player.elo - lobbyElo) < 100:
		return true	
	return false
