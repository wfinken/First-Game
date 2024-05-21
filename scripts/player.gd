# This script is attached to a 2D character node in Godot
extends CharacterBody2D

# Define constants for movement speed and jump velocity
const SPEED = 130.0  # How fast the character moves horizontally (pixels per second)
const JUMP_VELOCITY = -300.0  # Initial upward velocity when jumping

# Get a reference to the AnimatedSprite2D node (assumes it's a child of this node)
@onready var animated_sprite = $AnimatedSprite2D

# This function is called every physics frame to update the character's movement
func _physics_process(_delta):
	# 1. Get input direction
	# This line calculates the direction the player wants to move based on input actions. 
	# It's a vector that can have values of -1, 0, or 1 for x and y directions
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	# 2. Flip the sprite horizontally (if moving left or right)
	# This ensures the character is facing the correct direction based on movement input.
	if direction.x > 0:  # If moving right, flip the sprite to face right
		animated_sprite.flip_h = false
	elif direction.x < 0: # If moving left, flip the sprite to face left
		animated_sprite.flip_h = true

	# 3. Calculate and apply movement
	var current_speed = velocity.length() # Calculate the current speed by finding the magnitude of the velocity vector

	# If the direction vector is not zero (meaning there is input), then set the velocity to match it
	if direction != Vector2.ZERO:  # If there's movement input:
		# Set velocity to the input direction, normalized (length of 1) and scaled by SPEED.
		velocity = direction.normalized() * SPEED
		current_speed = SPEED  # Set the current speed to the maximum speed

	# If there is no movement input, then gradually slow down the character
	else:
		# Gradually decrease the speed towards zero using a smooth transition.
		current_speed = move_toward(current_speed, 0, SPEED)

		# If the speed is greater than 0, we need to scale the velocity by the current speed.
		if current_speed > 0:
			# Apply the adjusted speed to the normalized velocity to keep the character moving in the correct direction.
			velocity = velocity.normalized() * current_speed  
		else:
			# If the speed is 0, set the velocity to zero as well.
			velocity = Vector2.ZERO  # Stop completely when speed is 0

	# Use the built-in move_and_slide function to handle collision detection and movement.
	move_and_slide()  
