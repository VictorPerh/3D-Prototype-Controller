class_name State   # THIS IS A DEFAULT TEMPLATE STATE SCRIPT

extends Node

signal transition(new_state_name: StringName)

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
