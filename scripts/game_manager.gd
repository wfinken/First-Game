extends Node  # This script is attached to a basic Node in the Godot scene tree

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if the game is running on a dedicated server (i.e., without a graphical interface)
	if OS.has_feature("dedicated_server"): 
		print("Starting dedicated server...")  # Print a message to the console

		# Call a function (likely in another script called "MultiplayerManager") to initiate the server setup.
		MultiplayerManager.become_host()  
		
	$MainMenu/MultiplayerHUD/Panel/VBoxContainer/HostGame.connect("pressed",become_host)
	$MainMenu/MultiplayerHUD/Panel/VBoxContainer/JoinAsPlayer2.connect("pressed",join_as_player_2)
# Function to start hosting a multiplayer game
func become_host():
	print("Become host pressed")  # Print a message to the console (likely for debugging)
	MultiplayerManager.become_host()  # Call the same function from the "_ready" method to start hosting
	$MainMenu.queue_free() # Get a node with the name "MultiplayerHUD" and remove it
	$PlayerHud.show()
	
# Function to join an existing multiplayer game as player 2
func join_as_player_2():
	print("Join as player 2")  # Print a message to the console (likely for debugging)
	MultiplayerManager.join_as_player_2()  # Call a function (likely in the "MultiplayerManager" script) to join the game as player 2
	$MainMenu.queue_free() # Get a node with the name "MultiplayerHUD" and remove it
	$PlayerHud.show()
