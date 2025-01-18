extends CharacterBody3D


@export_category("Camera Variables")
@export var camera_hozirontal: Node3D
@export var camera_vertical: Node3D
@export var playerCamera: Camera3D
@export var camSensitivity: float = 1
@export var cameraDistance: float = 3

var upClamp: float = deg_to_rad(-90)
var downClamp: float = deg_to_rad(90)

#Camera Perspective
enum CamPerspective {FPP, TPP}
@export var cameraView : CamPerspective

@export_category("Player Variables")

@export_subgroup("Player Visuals")
@export var playerBody: Node3D
@export var anim_tree: AnimationTree
@export var anim_player: AnimationPlayer

@export_subgroup("Player Movement Variables")
@export var MAIN_SPEED:float = 250
var speed: float = MAIN_SPEED
@export var jump_velocity: float = 4.5
@export_range(5, 10, 0.1) var crouchSpeed: float = 7.0
@export var crouchCollision: ShapeCast3D
@export_range(50.0, 80.0) var crouchSpeedPercentage: float = 50
var canMove: bool = false

var rotation_direction: float
var movement_velocity: Vector3
var isMoving: bool = true
var isCrouching: bool = false

@export_subgroup("Control Conditions")
@export var toggleCrouch: bool = true #currently inactive

func _ready() -> void:
	Global.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #hides mouse
	crouchCollision.add_exception($".") #crouch collision will ignore the player

#Camera Free Look
func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		camera_hozirontal.rotate_y(-event.relative.x * (0.005 * camSensitivity))
		camera_vertical.rotate_x(-event.relative.y * (0.005 * camSensitivity) )
		camera_vertical.rotation.x = clamp(camera_vertical.rotation.x, upClamp, downClamp)



func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Player.SwitchCamera"):
		switchCamera()
	
	if event.is_action_pressed("Player.Crouch"):
		#crouch()
		crouchControls(event)


func _physics_process(delta: float) -> void:
	
	Global.debug.add_property("Movement Speed", speed, 1)
	Global.debug.add_property("Crouch State", isCrouching, 3)
	Global.debug.add_property("FPS", Global.debug.frames_per_second, 0)
	Global.debug.add_property("Coordinates", position, 5)
	Global.debug.add_property("is on floor", is_on_floor(), 6)
	Global.debug.add_property("velocity", velocity, 7)
	Global.debug.add_property("canMove?", canMove, 9)
	
#	anim_tree.set("parameters/conditions/canMove", canMove)
#	anim_tree.set("parameters/conditions/idle", !canMove)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("Player.Jump") and is_on_floor() and isCrouching == false:
		velocity.y = jump_velocity

	#Get the Input Values
	var input_dir := Vector3.ZERO
	input_dir.x = Input.get_axis("Player.Left", "Player.Right")
	input_dir.z = Input.get_axis("Player.Forward", "Player.Backward")
	
	Global.debug.add_property("Input Direction", input_dir, 2)
	
	#Set Input Direction according to Camera
	input_dir = input_dir.rotated(Vector3.UP, camera_hozirontal.rotation.y).normalized()
	movement_velocity = input_dir * speed * delta
	#apply new velocity to original and lerp
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, 50 * delta) # here it lerps from current velocity to applied 
	velocity.x = applied_velocity.x # now sets the custom velocity to the original variable
	velocity.z = applied_velocity.z # same here
	
	#root motion
	if input_dir == Vector3.ZERO:
		canMove = false
	else:
		canMove = true
	
	
	move_and_slide()
	match cameraView:
		CamPerspective.FPP:
			camera_vertical.spring_length = 0
			playerBody.rotation.y = camera_hozirontal.rotation.y
		CamPerspective.TPP:
			camera_vertical.spring_length = cameraDistance
			if Vector2(velocity.z, velocity.x).length() > 0:
				rotation_direction = Vector2(-velocity.z, -velocity.x).angle()
				playerBody.rotation.y = lerp_angle(playerBody.rotation.y, rotation_direction, delta * 10)
	

	animationParemeters()

func switchCamera():
	if cameraView == CamPerspective.FPP:
		cameraView = CamPerspective.TPP
	else:
		cameraView = CamPerspective.FPP

func animationParemeters():
	pass
	#anim_tree.set("parameters/conditions/startmove", isMoving)
	#anim_tree.set("parameters/conditions/idle", !isMoving)


func crouchControls(event): #switches between hold crouch or tap to crouch
	if event.is_action_pressed("Player.Crouch") and toggleCrouch == true:
		crouch()

func crouch():
	if isCrouching == true and crouchCollision.is_colliding() == false:
		crouching(false)
	elif isCrouching == false:
		crouching(true)
	
func crouching(state: bool):
	match state:
		true:
			anim_player.play("Crouch", -1, crouchSpeed)
			movementSpeed("crouching")
		false:
			anim_player.play("Crouch", -1, -crouchSpeed, true)
			movementSpeed("default")

func crouchCheck():
	if crouchCollision.is_colliding() == false:
		crouching(false) #will release the crouch after it stops colliding
	if crouchCollision.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		crouchCheck()

func movementSpeed(state: String):
	match state:
		"default":
			speed = MAIN_SPEED
		"crouching":
			speed = speed * crouchSpeedPercentage / 100


func _on_player_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "Crouch":
		isCrouching = !isCrouching
