tool
extends Control

onready var DialogMenu : MenuButton = self.get_node("HSplitContainer/MainWindow/Toolbar/DialogMenu")
enum DIALOGMENU {
	SAVE     = 0,
	SAVEALL  = 1,
	BAKE     = 2,
	BAKEOPEN = 3,
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

var settings_save_path : String     = "res://addons/DialogEditor/settings.json"
var save_path          : String     = "res://addons/DialogEditor/Saves/"
var bake_path          : String     = "res://Dialogs"
var skip_empty         : bool       = true
var bake_language      : String     = "en"
var node_templates     : Array      = [] 
var node_values        : Dictionary = {}

func _ready() -> void:
	update_settings()
	if DialogMenu:
		DialogMenu.get_popup().connect("id_pressed", self, "dialog_menu_id_pressed")
		DialogMenu.get_popup().set_item_shortcut(1, create_shortcut(KEY_S, true))
	if NodeMenu:
		NodeMenu.get_popup().connect("id_pressed", self, "node_menu_id_pressed")
		NodeMenu.get_popup().set_item_shortcut(0, create_shortcut(KEY_S, false, true))
		NodeMenu.get_popup().set_item_shortcut(1, create_shortcut(KEY_T, false, true))
		NodeMenu.get_popup().set_item_shortcut(2, create_shortcut(KEY_B, false, true))
		NodeMenu.get_popup().set_item_shortcut(3, create_shortcut(KEY_E, false, true))
	if GraphContainer:
		GraphContainer.connect("tab_changed", self, "change_aktiv_graph")
	for sibling in get_parent().get_children():
		if sibling.name == "Dialog Manager":
			sibling.connect("open_dialog_graph", self, "open_graph")
		if sibling.name == "Editor Settings":
			sibling.connect("update_settings", self, "update_settings")

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
			if current_graph:
				bake_graph(current_graph.dialog_name)
		DIALOGMENU.BAKEOPEN:
			bake_open()
		DIALOGMENU.CLOSE:
			if current_graph:
				current_graph.save_graph()
				current_graph.queue_free()
		DIALOGMENU.CLOSEALL:
			if GraphContainer.get_child_count() != 0:
				for graph in GraphContainer.get_children():
					graph.save_graph()
					graph.queue_free()

func bake_open() -> void:
	for graph in GraphContainer.get_children():
		if graph.has_method("bake_graph"):
			bake_graph(graph.dialog_name)

func bake_graph(graph_name : String) -> void:
	var dir    : Directory  = Directory.new()
	var f      : File       = File.new()
	var result : Dictionary = get_graph_by_name(graph_name).bake_graph(skip_empty)
	if !dir.dir_exists(str(bake_path, bake_language)):
		dir.make_dir_recursive(str(bake_path, bake_language))
	f.open(str(bake_path, bake_language, "/",graph_name, ".json"), f.WRITE)
	f.store_string(to_json(result))
	f.close()

func node_menu_id_pressed(id : int) -> void:
	if GraphContainer.get_child_count() != 0:
		GraphContainer.get_child(GraphContainer.current_tab).add_node(id)

func change_aktiv_graph(tab : int) -> void:
	if current_graph:
		current_graph.save_graph()
	GraphContainer.current_tab = tab
	current_graph = GraphContainer.get_children()[tab]

func open_graph(path : String, template : int = -1, close : bool = false) -> void:
	if !graph_opend(path.get_file().trim_suffix(".tscn")):
		var Graph : GraphEdit
		var f     : File      = File.new()
		if f.file_exists(path):
			Graph = load(path).instance()
		else:
			Graph = load(empty_graph).instance()
			if f.file_exists(node_templates[template]):
				f.open(node_templates[template], f.READ)
				node_values = parse_json(f.get_as_text())
				f.close()
			if node_values.has("node_values"):
				Graph.node_values = node_values["node_values"]
			Graph.dialog_name = path.get_file().trim_suffix(".tscn")
		Graph.name = path.get_file().trim_suffix(".tscn")
		Graph.editor = self
		GraphContainer.add_child(Graph)
		Graph.save_graph()
		if close == true:
			print("close dialog", close)
			Graph.queue_free()
		GraphContainer.current_tab = GraphContainer.get_child_count() - 1
	else:
		var i : int = 0
		for graph in GraphContainer.get_children():
			if graph.name == path.get_file().trim_suffix(".tscn"):
				GraphContainer.current_tab = i
				break
			i += 1

func graph_opend(graph_name : String) -> bool:
	for graph in GraphContainer.get_children():
		if graph.name == graph_name:
			return true
			break
	return false

func debug_message(msg : String) -> void:
	DebugLabel.text = msg

func update_settings() -> void:
	var f : File = File.new()
	if f.file_exists(settings_save_path):
		f.open(settings_save_path, f.READ)
		var data = parse_json(f.get_as_text())
		save_path      = data["SavePath"]
		if !save_path.ends_with("/"):
			save_path  = str(save_path, "/")
		bake_path      = data["BakePath"]
		if !bake_path.ends_with("/"):
			bake_path  = str(bake_path, "/")
		bake_language  = data["DefaultBakeLanguage"]
		node_templates = data["NodeTemplates"]
		skip_empty     = data["SkipEmptyNodes"]
		f.close()
		node_templates.push_front("res://addons/DialogEditor/DefaultTemplate.json")

func get_graph_by_name(graph_name) -> Node:
	for node in GraphContainer.get_children():
		if node.name == graph_name:
			return node
	open_graph(graph_name)
	return get_graph_by_name(graph_name)

# Creats an Shortcut
func create_shortcut(key : int = KEY_S, strg : bool = false, alt : bool = false) -> ShortCut:
	# creates new ShortCut
	var s   : ShortCut      = ShortCut.new()
	# creates new InputKeyEvent
	var iek : InputEventKey = InputEventKey.new()
	# sets the iek scancode
	iek.set_scancode(key)
	# if it should use STRG/CMD
	iek.control = strg
	iek.command = strg
	# if it should use ALT
	iek.alt     = alt
	# sets the Shortcuts shortcut
	s.set_shortcut(iek)
	return s
