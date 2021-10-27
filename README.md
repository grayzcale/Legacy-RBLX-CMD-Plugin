![image](https://user-images.githubusercontent.com/58129405/139062677-90f56ffd-8628-4c98-99d0-572e0dc97f89.png)

<hr>

- Plugin: https://www.roblox.com/library/7850002844/CMD
- Devforum: -
<hr>

Use this extremely versatile plugin to improve your workflow on Roblox Studio by quickly executing custom shortcuts.

#### How to plugin works:
When you press the shortcut key, a new object Chain is created. This object is responsible for handling all the Nodes in a refined matter. It kind of resembles the idea of a chain with perfect links between, hence the name *Chain*. The CommandNode always comes first in the Chain. The next Nodes are created as they are defined in your command script. All of the Nodes get inherited from a superclass called Node. This is to allow easy access to add extra nodes in the future and maintain good code structure.

<br>

#### Getting started:

After you install the plugin, go to File > Advanced > Customize Shorcuts, search for "cmd+," and set the shortcut to your preference. A preferred shortcut is the "\`" key. After you assign your shortcut, press the key to open up the CMD+ CommandNode that is used to display all of the commands. You will then see a list of all the commands.

For navigation, use your mouse normally or use the up, down, and enter keys for selection. Start typing immediately to give input to the active Node.

<br>

#### Creating custom commands:
To create a new command, add a new folder to game.ServerStorage called "CMD+". Insert a new modulescript in the folder and copy the template below:
```lua
return {

	metadata = {
		id = "";   --unique id for every command; must be different for each cmd
		display = "";   --display-text for command
		inputRequired = false;   --enable if command requires input
	};
	
	--main function
	execute = function(chain)
		

		chain:Dispose() --do not forget to close the chain
	end;
	
}
```

<br>

#### Available Nodes:

![image](https://user-images.githubusercontent.com/58129405/139063916-e4244dd7-ed35-4cd4-902a-1db74e778496.png)

### API:

Before starting, please note that you must remember to close the Chain by using `chain:Dispose()` at the end of your custom command. Depending on your shortcut you should also close the Chain if the input of any nodes is nil.

<br>

#### SelectionNode:
```lua
<SelectionNode> chain:Node("SelectionNode") --create SelectionNode

<SelectionNode> SelectionNode:Set({
	title = ""; --title of Node, default: ""
	placeholder = ""; --placeholder text of Node, default: ""
	ignoreCase = false; --disable/enable IgnoreCase option, default: true
})

<table> SelectionNode:Get()
--returns a table of selected objects by user
--WILL RETURN EMPTY TABLES IF NO OBJECTS ARE SELECTED, MAKE SURE TO HANDLE
--yields until input is given
--nil if no input received, CLOSE CHAIN
```

<br>

#### InputNode:
```lua
<InputNode> chain:Node("InputNode") --create InputNode

<ListNode> ListNode:Set({
	title = ""; --title of Node, default: ""
	placeholder = ""; --placeholder text of Node, default: ""
	list = {
		{"", false, Color3.fromRGB()} --format: {option name, true to show icon, icon color}
	};
})

<string, boolean> InputNode:Get()
--returns a string inputted by the user and a boolean if IgnoreCase was selected
--yields until input is given
--nil if no input received, CLOSE CHAIN
```

<br>

#### ChoiceNode:
```lua
<ChoiceNode> chain:Node("ChoiceNode") --create ChoiceNode

<ChoiceNode> ChoiceNode:Set({
	title = ""; --title of Node, default: ""
	text = ""; --text display message, default: ""
		options = {
			{"", ""} --format: {key, text}
	};
})

<string> ChoiceNode:Get()
--returns a string key indicating which choice was selected
--yields until input is given
--nil if no input received, CLOSE CHAIN
```

<br>

#### ListNode:
```lua
<ListNode> chain:Node("ListNode") --create ListNode

<ListNode> ListNode:Set({
	title = ""; --title of Node, default: ""

	text = ""; --text display message, default: ""
		options = {
			{"", ""} --format: {"key", "message"}
	};
})

<string> ListNode:Get()
--returns a string key indicating which option from the list was selected
--yields until input is given
--nil if no input received, CLOSE CHAIN
```
