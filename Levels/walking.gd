extends Node3D

@onready var anim_tree = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.play("Breathing Idle/idluh", -1, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
