extends CharacterBody2D  # This script controls a 2D character with physics

# Define movement constants
const SPEED = 130.0         # Horizontal movement speed in pixels per second
const JUMP_VELOCITY = -300.0  # Initial upward velocity for jumping

# Get a reference to the AnimatedSprite2D node for animations
@onready var animated_sprite = $AnimatedSprite2D

# Movement and state variables
var direction: Vector2 = Vector2.ZERO     # The direction the character is moving
var do_jump = false                      # Whether the character should jump (not used in this snippet)
var alive = true                         # Whether the character is alive


@export var zoom_min = 0.1  # Minimum zoom level
@export var zoom_max = 4.0   # Maximum zoom level
@export var zoom_speed = 0.1 # Zoom speed per scroll unit

# Export the player ID so it can be set in the Godot editor
@export var player_id := 1:
	# Setter function to update the player ID and set multiplayer authority
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)  # Assumes InputSynchronizer node exists

# Called when the node enters the scene tree
func _ready():
	# Check if this is the local player (the one controlled by the user on this machine)
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()       # Make this player's camera the active one
	else:
		$Camera2D.enabled = false      # Disable the camera for other players (they have their own)

# Function to apply character animations based on movement (not fully implemented)
func _apply_animations(_delta):
	# Flip the sprite horizontally based on the direction of movement
	if direction.x > 0: 
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

	# Placeholder for animation logic (idle, run, jump)
	# ... You would add the animation playing code here ...
	pass

# Function to handle character movement based on input
func _apply_movement_from_input(_delta):
	# Get the input direction from an InputSynchronizer node (presumably synced across the network)
	direction = %InputSynchronizer.input_direction  

	# Movement logic
	var current_speed = velocity.length()  # Get the current speed magnitude

	# If there's input (direction is not zero)
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED       # Move in the given direction at max speed
		current_speed = SPEED                           # Update the speed to the maximum

	# If there's no input (direction is zero)
	else:
		# Gradually decrease the speed towards zero
		current_speed = move_toward(current_speed, 0, SPEED) 

		# If still moving, apply the reduced speed to the existing velocity
		if current_speed > 0:
			velocity = velocity.normalized() * current_speed  
		else:
			velocity = Vector2.ZERO   # Stop completely when speed reaches 0

	# Move the character using the calculated velocity and handle collisions
	move_and_slide()

# Called every physics frame to update the character's state
func _physics_process(delta):
	# Check if this is the server (the authority for game logic)
	if multiplayer.is_server():
		if not alive:                    # If the character is dead...
			_set_alive()                  # ...respawn (function not shown)
		_apply_movement_from_input(delta)  # Apply movement based on input

	# Apply animations on the server and on clients if in host mode 
	# (to avoid animation jitters on the host)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:  
		_apply_animations(delta)         # Apply animations (this could be done on the client too)
	get_node("/root/Game/PlayerHud/PlayerHudBox/Panel/VBoxContainer/Label").text = str(self.position)
	
# Function to mark the character as dead (not fully implemented)
func mark_dead():
	print("Mark player dead!")
	alive = false
	$CollisionShape2D.set_deferred("disabled", true) # Disable collision shape (optional)
	$RespawnTimer.start()                             # Start a respawn timer (not shown)

# Function to respawn the character (not fully implemented)
func _respawn():
	print("Respawned!")
	position = MultiplayerManager.respawn_point     # Reset position
	$CollisionShape2D.set_deferred("disabled", false)  # Re-enable collision shape (if disabled)

# Function to set the character back to alive (not fully implemented)
func _set_alive():
	print("alive again!")
	alive = true
	Engine.time_scale = 1.0   # Unpause the game (if it was paused on death)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var zoom_direction = 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1

			# Get current zoom level as a Vector2
			var zoom = $Camera2D.zoom  

			# Calculate new zoom level by scaling both x and y components
			var new_zoom = zoom * Vector2(1 + zoom_direction * zoom_speed, 1 + zoom_direction * zoom_speed)

			# Clamp each component of the zoom vector individually
			new_zoom.x = clamp(new_zoom.x, zoom_min, zoom_max)
			new_zoom.y = clamp(new_zoom.y, zoom_min, zoom_max)

			# Set the updated zoom on the camera
			$Camera2D.zoom = new_zoom 
