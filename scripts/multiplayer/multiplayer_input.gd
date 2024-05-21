extends MultiplayerSynchronizer  # Base class for nodes that synchronize state over a network

# Get a reference to a parent node named "Player" (the character this script controls)
@onready var player = $".."

# A Vector2 to store the input direction
var input_direction: Vector2

# Called when the node is added to the scene tree (before the first frame is rendered)
func _ready():
	# Check if this node is not the authoritative peer for this player
	# (The "authoritative peer" is the one responsible for simulating this player's actions)
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		# If not the authoritative peer, disable processing and physics processing
		# (This prevents the node from running its own logic, as the authoritative peer will handle it)
		set_process(false)
		set_physics_process(false)

	# Get initial input direction from input actions
	input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),  # Horizontal input (-1 to 1)
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")      # Vertical input (-1 to 1)
	)

# Called during the physics simulation step (typically for physics-related logic)
func _physics_process(_delta):
	# Update the input direction vector from the latest input actions (this could be done in _process too)
	input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),  # Horizontal input (-1 to 1)
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")      # Vertical input (-1 to 1)
	)

# Called every frame (typically for non-physics logic)
func _process(_delta):
	pass  # This function currently does nothing, but you would put your character movement code here if this were the authoritative peer
