# This script will control the overall multiplayer aspects of your game
extends Node

# Define constants for the server's network settings
var SERVER_PORT = 8080  # The port number the server will listen on
var SERVER_IP = "127.0.0.1"  # This is the loopback IP address, used for testing on the same computer

# Preload the scene that represents an individual player in the multiplayer game
var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")

# Preload the GameLevel scene for loading after creating or joining the server
var game_level = preload("res://scenes/game_level.tscn")

# Variables to track the game state
var _players_spawn_node  # Node where player instances will be added
var host_mode_enabled = false  # Whether this instance is acting as the host
var multiplayer_mode_enabled = false  # Whether multiplayer is currently active
var respawn_point = Vector2(30, 20)  # Default position for new players

# Function to set up this instance as the multiplayer host
func become_host():
	var instantiated_level = game_level.instantiate()
	instantiated_level.name = "GameLevel"
	get_window().add_child(instantiated_level)
	# Get the node named "Players" in the current scene, which will be used as the parent for player instances
	_players_spawn_node = get_node("/root/GameLevel/PlayersSpawner")
	
	SERVER_PORT = int(get_node("/root/Game/MainMenu/MultiplayerHUD/Panel/VBoxContainer/ServerPort").get_text())
	SERVER_IP = get_node("/root/Game/MainMenu/MultiplayerHUD/Panel/VBoxContainer/ServerHost").get_text()
	# Update game state variables to indicate we are hosting
	multiplayer_mode_enabled = true
	host_mode_enabled = true

	# Create a new ENetMultiplayerPeer object to manage the network connection
	var server_peer = ENetMultiplayerPeer.new()
	# Start the server on the specified port and with a maximum of 32 players
	server_peer.set_bind_ip(SERVER_IP)
	server_peer.create_server(SERVER_PORT, 32) 
	

	# Set the project's multiplayer peer to the newly created server peer
	multiplayer.multiplayer_peer = server_peer

	# Connect signals to handle player joining and leaving events
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)

	# Remove the single player from the scene (if it exists)
	_remove_single_player()

	# If this is not a dedicated server (i.e., it has a graphical interface), add the host as player 1
	if not OS.has_feature("dedicated_server"): 
		_add_player_to_game(1)
		
	print("Starting host on port " + str(SERVER_PORT))  # Print a message to the console
# Function to connect to the host as player 2
func join_as_player_2():
	var instantiated_level = game_level.instantiate()
	instantiated_level.name = "GameLevel"
	get_window().add_child(instantiated_level)
	# Update the game state to indicate we are in multiplayer mode
	multiplayer_mode_enabled = true
	
	SERVER_PORT = int(get_node("/root/Game/MainMenu/MultiplayerHUD/Panel/VBoxContainer/ServerPort").get_text())
	SERVER_IP = get_node("/root/Game/MainMenu/MultiplayerHUD/Panel/VBoxContainer/ServerHost").get_text()
	# Create a new ENetMultiplayerPeer object to manage the network connection
	var client_peer = ENetMultiplayerPeer.new()
	# Connect to the server at the specified IP and port
	client_peer.create_client(SERVER_IP, SERVER_PORT) 

	# Set the project's multiplayer peer to the newly created client peer
	multiplayer.multiplayer_peer = client_peer

	# Remove the single player from the scene (if it exists)
	_remove_single_player()
	print("Player 2 joined " + SERVER_IP + ":" + str(SERVER_PORT))  # Print a message to the console
# Function to add a player to the game when they connect
func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)  # Print a message to the console

	# Create a new instance of the multiplayer player scene
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id  # Set the player ID
	player_to_add.name = str(id)  # Set the node name to the player ID (for easy identification)

	# Add the new player instance as a child of the players_spawn_node in the scene tree
	_players_spawn_node.add_child(player_to_add, true) 

# Function to remove a player from the game when they disconnect
func _del_player(id: int):
	print("Player %s left the game!" % id)  # Print a message to the console

	# Check if a node with the player's ID exists (this is the player's instance)
	if not _players_spawn_node.has_node(str(id)):
		return  # If not found, do nothing
	
	# Get the player's node and queue it for deletion (removed from the scene tree)
	_players_spawn_node.get_node(str(id)).queue_free()


# Function to remove the single-player character from the scene when switching to multiplayer
func _remove_single_player():
	print("Remove single player")  # Print a message to the console

	# Find the node named "Player" in the current scene (this is the single-player character)
	var player_to_remove = get_node("/root/GameLevel/Player")
	# Queue the single-player character for deletion (removed from the scene tree)
	player_to_remove.queue_free()
