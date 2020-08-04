tool
extends Control

onready var DialogMenu : MenuButton = self.get_node("HSplitContainer/MainWindow/Toolbar/DialogMenu")
enum DIALOGMENU {
	SAVE     = 0,
	SAVEALL  = 1,
	BAKE     = 2,
	BAKEOPEN = 3,
	BAKEALL  = 4,
	CLOSE    = 5,
	CLOSEALL = 6
}

onready var NodeMenu : MenuButton = self.get_node("HSplitContainer/MainWindow/Toolbar/NodeMenu")
enum NODEMENU {
	START = 0
	TEXT  = 1
}

onready var GraphContainer : TabContainer = self.get_node("HSplitContainer/MainWindow/TabContainer")
onready var DebugLabel     : Label        = self.get_node("HSplitContainer/MainWindow/debug")

var current_graph : GraphEdit
var empty_graph   : String    = "res://addons/DialogEditor/GraphEditor/Graph/GraphEdit.tscn"

func _ready() -> void:
	if DialogMenu:
		DialogMenu.get_popup().connect("id_pressed", self, "dialog_menu_id_pressed")
	if NodeMenu:
		NodeMenu.get_popup().connect("id_pressed", self, "node_menu_id_pressed")
	if GraphContainer:
		GraphContainer.connect("tab_changed", self, "change_aktiv_graph")
	for sibling in get_parent().get_children():
		if sibling.name == "Dialog Manager":
			sibling.connect("open_dialog_graph", self, "open_graph")

func dialog_menu_id_pressed(id : int) -> void:
	match id:
		DIALOGMENU.SAVE:
			if current_graph:
				current_graph.save_graph()
		DIALOGMENU.SAVEALL:
			if GraphContainer.get_child_count() != 0:
				for graph in GraphContainer.get_children():
					graph.save_graph()
		DIALOGMENU.BAKE:
			pass
		DIALOGMENU.BAKEOPEN:
			pass
		DIALOGMENU.BAKEALL:
			pass
		DIALOGMENU.CLOSE:
			if current_graph:
				current_graph.save_graph()
				current_graph.queue_free()
		DIALOGMENU.CLOSEALL:
			if GraphContainer.get_child_count() != 0:
				for graph in GraphContainer.get_children():
					graph.save_graph()
					graph.queue_free()

func node_menu_id_pressed(id : int) -> void:
	if GraphContainer.get_child_count() != 0:
		GraphContainer.get_child(GraphContainer.current_tab).add_node(id)

func change_aktiv_graph(tab : int) -> void:
	if current_graph:
		current_graph.save_graph()
	GraphContainer.current_tab = tab
	current_graph = GraphContainer.get_children()[tab]

func open_graph(path : String) -> void:
	var Graph : GraphEdit
	var f     : File      = File.new()
	if f.file_exists(path):
		Graph = load(path).instance()
	else:
		Graph = load(empty_graph).instance()
	Graph.name = path.get_file().trim_suffix(".tscn")
	Graph.editor = self
	GraphContainer.add_child(Graph)

func debug_message(msg : String) -> void:
	DebugLabel.text = msg
