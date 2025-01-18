extends PanelContainer

@onready var property_container = %VBoxContainer

#var property
var frames_per_second: String

func _ready() -> void:
	Global.debug = self # assigns this script to the global variable
	visible = false
	
	#add_debug_property("FPS", frames_per_second)
	

func _process(delta: float) -> void:
	if visible:
		frames_per_second = "%.2f" % (1.0/delta)
		#frames_per_second = Engine.get_frames_per_second()
		#property.text = property.name + ": " + frames_per_second
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("UI.Debug"): #toggle debug panel
		visible = !visible

func add_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false) # tries to find label node with same name
	if !target: #if there is no current label node for property
		target = Label.new() #creates new label node
		property_container.add_child(target) #adds new child as a node to vbox container
		target.name = title #sets the name to the title
		target.text = target.name + ": " + str(value) #set text value
	elif visible:
		target.text = title + ": " + str(value) #update text value
		property_container.move_child(target, order) #reorder property based on given order value
	


#func add_debug_property(title: String, value):
	#property = Label.new() #creates new label node
	#property_container.add_child(property) #adds new child as a node to vbox container
	#property.name = title #sets the name to the title
	#property.text = property.name + value
