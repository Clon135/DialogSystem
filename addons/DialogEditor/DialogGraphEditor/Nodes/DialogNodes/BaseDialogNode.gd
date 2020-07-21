tool
extends GraphNode

var Colors : Array = [
	Color(1,1,1,1),         # Dialog
	Color(0,1,0.85,1),      # Name
	Color(0,1,0.5,1),       # String
	Color(0,1,0.5,1),       # Multiline String
	Color(0.25,0.5,0.85,1), # Integer
	Color(0.4,0.85,0.25,1), # float
	Color(0.9,0.2,0.2,1),   # bool
	Color(0.7,0.2,0.9,1),   # Texture
	Color(0.9,0.9,0.2,1)    # Sound
]

signal deleted_node(node_type)

export (int) var NodeIndexNumber

func _ready():
	
	self.connect("resize_request", self, "_on_BaseDialogNode_resize_request")
	self.connect("close_request", self, "_on_BaseDialogNode_close_request")

func get_node_type() -> int:
	return NodeIndexNumber

func _on_BaseDialogNode_close_request():
	close_node()
	emit_signal("deleted_node", NodeIndexNumber)
	self.queue_free()

func _on_BaseDialogNode_resize_request(new_minsize):
	resize_node(new_minsize)
	self.rect_size = new_minsize



# Overwrittabel functions

# called when node closes
func close_node() -> void:
	pass

# called when node is resized
func resize_node(new_minsize) -> void:
	pass

func update_connections(new_connection):
	
	get_parent().update()

func update_disconnection(new_disconnection):
	
	get_parent().update()

# used for saving
func set_owner(new_owner):
	self.owner = new_owner
	update_data()

func get_dialog() -> Dictionary:
	return {}

func update_data() -> void:
	pass

func get_parents_childe_by_name(childe_name : String):
	var children = get_parent().get_children()
	for child in children:
		if child.name == childe_name:
			return child
			break

func get_node_groupe() -> int:
	return 0













