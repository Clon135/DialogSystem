tool
extends Control

signal open_dialog(dialog_name)

var SavePath : String = "res://"

var dialog : Resource = load("res://addons/DialogEditor/DialogManager/DialogInstance.tscn")

onready var CreateNewDialogDialog : WindowDialog  = self.get_node("CreateNewDialogDialog")
onready var DialogList            : VBoxContainer = self.get_node("HSplitContainer/Main/VBoxContainer/Dialogs/TextEdit/ScrollContainer/List")

func _ready() -> void:
	load_dialogs()

func _on_Add_pressed() -> void:
	CreateNewDialogDialog.popup_centered()

func get_save_path() -> String:
	
	var f = File.new()
	
	if f.file_exists("res://addons/DialogEditor/settings.json"):
		f.open("res://addons/DialogEditor/settings.json", f.READ)
		SavePath = parse_json(f.get_as_text())["SavePath"]
		f.close()
	else:
		SavePath = "res://addons/DialogEditor/Saves"
	
	if !SavePath.ends_with("/"):
		SavePath = str(SavePath, "/")
	
	return SavePath

func _on_Create_pressed() -> void:
	
	var text = $CreateNewDialogDialog/VBoxContainer/HBoxContainer/LineEdit.text
	
	if check_dialog_file_exists(text):
		$CreateNewDialogDialog/VBoxContainer/Label.text = "Dialog Already Exists"
	else:
		var d = dialog.instance()
		d._on_create(text, get_new_id(), self)
		DialogList.add_child(d)
		$CreateNewDialogDialog/VBoxContainer/HBoxContainer/LineEdit.text = ""
		CreateNewDialogDialog.hide()

func _on_Cancle_pressed() -> void:
	$CreateNewDialogDialog/VBoxContainer/HBoxContainer/LineEdit.text = ""
	CreateNewDialogDialog.hide()

func get_new_id(start : int = 0) -> int:
	
	var rtrn : int = start + DialogList.get_child_count() + 1
	
	if has_id(rtrn) || rtrn == 0:
		rtrn = get_new_id(rtrn)
	
	return rtrn

func has_id(_id : int) -> bool:
	
	for c in DialogList.get_children():
		if c.get_id() == _id:
			return true
			break
	
	return false

func check_dialog_file_exists(FileName : String) -> bool:
	
	var f : File = File.new()
	
	if f.file_exists(str(get_save_path(), FileName, ".data")):
		return true
	else:
		return false

func load_dialogs() -> void:
	
	if DialogList.get_child_count() != 0:
		for c in DialogList.get_children():
			c.save_dialog()
			c.queue_free()
	
	var dir : Directory = Directory.new()
	var f   : File      = File.new()
	
	if dir.open(get_save_path()) == OK:
		dir.list_dir_begin()
		var FileName : String = dir.get_next()
		while FileName != "":
			if !dir.current_is_dir():
				if FileName.ends_with(".data"):
					var d = dialog.instance()
					print(str(SavePath, FileName))
					f.open(str(SavePath, FileName), f.READ)
					var data = f.get_var()
					d._on_load(data, self)
					f.close()
					DialogList.add_child(d)
			FileName = dir.get_next()

















