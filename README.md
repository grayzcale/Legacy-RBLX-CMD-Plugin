![image](https://user-images.githubusercontent.com/58129405/139062677-90f56ffd-8628-4c98-99d0-572e0dc97f89.png)

<hr>

Use this extremely versatile plugin to improve your workflow on Roblox Studio by quickly executing custom shortcuts.

#### How to use:

After you install the plugin, go to File > Advanced > Customize Shorcuts, search for "cmd+," and set the shortcut to your preference. A preferred shortcut is the "\`" key. After you assign your shortcut, press the key to open up the CMD+ CommandNode that is used to display all of the commands. You will then see a list of all the commands.

For navigation, use your mouse normally or use the up, down, and enter keys for selection. Start typing immediately to give input to the active Node.

<details>

<summary>Visual demo</summary>

![demo|video](upload://1qvgdeS8btSMgpfubhcmDUnUcgv.mp4)

The example above is a default command using the code:
```lua
local changeHistoryService = game:GetService("ChangeHistoryService")

return {
	
	metadata = {
		id = "DefaultCMD:RenameObjects";   --unique id for every command
		display = "Rename object(s)";   --display-text for command
		inputRequired = true;   --enable if command requires input
	};
	
	execute = function(chain)
		
		--Create a new SelectionNode with optional settings and make sure input was recieved
		local selection, ignoreCase = chain:Node("SelectionNode"):Set({
			title = "Select object(s)";
		}):Get()
		if not selection or #selection < 1 then chain:Dispose() return end
		
		
		--Create a new InputNode with optional settings and make sure input was recieved
		local newName, ignoreCase = chain:Node("InputNode"):Set({
			title = "Rename selected object(s)";
			placeholder = "enter a new name...";
			ignoreCase = false;
		}):Get()
		
		if newName then
			
			--Set waypoint before action to allow undo
			changeHistoryService:SetWaypoint("Renaming Objects")
			
			--Rename selected objects
			for _, obj in ipairs(selection) do
				obj.Name = newName
			end
			
			--Set waypoint after action to allow undo
			changeHistoryService:SetWaypoint("Renamed Objects")
		end
		
		--Close Chain after use
		chain:Dispose()
		
	end;
	
}
```

</details>

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

<InputNode> InputNode:Set({
	title = ""; --title of Node, default: ""
	placeholder = ""; --placeholder text of Node, default: ""
	ignoreCase = false; --disable/enable IgnoreCase option, default: true
})

string, boolean InputNode:Get()
--returns a string inputted by the user and a boolean if ignorecase was selected
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
			{"", ""} --format: {"key", "message"}
	};
})

string, boolean ChoiceNode:Get()
--returns a string key indicating which choice was selected
--yields until input is given
--nil if no input received, CLOSE CHAIN
```

<br>

#### ListNode:
```lua
<SelectionNode> chain:Node("ChoiceNode") --create SelectionNode

<SelectionNode> SelectionNode:Set({
	title = ""; --title of Node, default: ""
	text = ""; --text display message, default: ""
		options = {
			{"", ""} --format: {"key", "message"}
	};
})

string, boolean ChoiceNode:Get()
--returns a string key indicating which choice was selected
--yields until input is given
--nil if no input received, CLOSE CHAIN
```
