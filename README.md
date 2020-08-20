# DialogSystem
 A Dialog System for Godot
 
 [wiki](https://github.com/Clon135/DialogSystem/wiki)
 
## **Getting Started**

Download the newest version under the Releases tab
choose between Example(includes an Example Project) or Addon(just the plugin)

if the Icons are not loading wait until it finished Importing them and turn the Plugin/Addon off and on again or reopen the Project. that should fix it.

### **Create your own Dialog**

1. Go to Dialog Editor (in the top mid of the Screen)
2. Press on the Left plus symbol 
3. enter a Name and ID and Choose your [Node Template](https://github.com/Clon135/DialogSystem/wiki/Node-Templates)  
4. Open your dialog by pressing the Play Button on your Dialog
5. Go to Graph Editor and add your Nodes

### **Bake your Dialog**

after making a Graph you have to bake the Dialog baking is very easy 

- Press the Dialog Dropdown and select Bake thats all
- or in the Dialog Manager press the oven symbol 

### **Using your Dialog**

for easier use of the Baked Dialogs you can use the Dialog class
create one like this 

```gdscript
var dialog : Dialog = Dialog.new()
```

**load your dialog 
from file:**
```gdscript
dialog.load_from_file(path_to_file)
```
**or with a Dictionary:**
```gdscript
dialog.load_from_dict(Dictionary)
```

**Get the Current Dialog:**
```gdscript
dialog.get_current_dialog()
```
returns a Dictionary with the Dialogs Values,Node ID and the Options

**if you only want the values do this:**
```gdscript
dialog.get_values()
```
returns an Array of all the values of the current dialog
the values are Structured like this
```json
{ "value_name": "value" }
```

**if you only want the Options you can do this:**
```gdscript
dialog.get_options()
```
this returns an Array of all the Options

**progressing the dialog is done by calling next like this:**
```gdscript
dialog.next()
```

more can you find in the [Dialog class wiki](https://github.com/Clon135/DialogSystem/wiki/Dialog-class) section
or in the Example Projects
