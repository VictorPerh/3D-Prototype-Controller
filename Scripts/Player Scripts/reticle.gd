extends CenterContainer

@export var dotRadius:float = 1.0
@export var dotColor: Color = Color.WHITE
@export var reticleLines: Array[Line2D]
@export var reticleSpeed: float = 0.25
@export var reticleDistance: float = 2.0
@export var playerController: CharacterBody3D


func _ready() -> void:
	queue_redraw()


func _process(_delta: float) -> void:
	adjust_reticle_lines()


func _draw():
	draw_circle(Vector2(0,0), dotRadius, dotColor)


func adjust_reticle_lines():
	var vel = playerController.get_real_velocity()
	var pos = Vector2(0,0)
	var speed = vel.length()
	
	#adjust reticle line position
	reticleLines[0].position = lerp(reticleLines[0].position, pos + Vector2(0, -speed * reticleDistance), reticleSpeed) #top
	reticleLines[1].position = lerp(reticleLines[1].position, pos + Vector2(speed * reticleDistance, 0), reticleSpeed) #right
	reticleLines[2].position = lerp(reticleLines[2].position, pos + Vector2(0, speed * reticleDistance), reticleSpeed) #bottom
	reticleLines[3].position = lerp(reticleLines[3].position, pos + Vector2(-speed * reticleDistance, 0), reticleSpeed) #left
