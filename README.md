![image](https://user-images.githubusercontent.com/58129405/139062677-90f56ffd-8628-4c98-99d0-572e0dc97f89.png)

<hr>

- Plugin: https://www.roblox.com/library/7850002844/CMD
- Devforum: https://devforum.roblox.com/t/cmd-execute-custom-commands/1527542
<hr>

Use this extremely versatile plugin to improve your workflow on Roblox Studio by quickly executing custom shortcuts.

#### How the plugin works:
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
		shortcut = {}; --optional table of KeyCode Enums
		inputRequired = false;   --enable if command requires input
	};
	
	--main function
	execute = function(chain)

		--create your nodes here

	end;
	
}
```

<br>

#### Example script for the default rename command:
```lua
local changeHistoryService = game:GetService("ChangeHistoryService")
local selectionService = game:GetService("Selection")

return {

	metadata = {
		id = "DefaultCMD:RenameObjects";   --unique id for every command
		display = "Rename object(s)";   --display-text for command
		shortcut = {Enum.KeyCode.LeftShift, Enum.KeyCode.R}; --optional shortcut
		inputRequired = false;   --enable if command requires input
	};

	execute = function(chain)
		
		--Create a new ChoiceNode with optional settings and make sure input was recieved
		local selectionType = chain:Node("ChoiceNode"):Set({
			title = "Selection type";
			text = "Select object(s) from...";
			choices = {
				{"s", "selection"};
				{"n", "name"};
			};
		}):Get()
		if not selectionType then return end
		
		--If selection is by name, get selection ancestor
		local service
		if selectionType == "n" then
			local list = {{"game", "All"}}
			for _, service in ipairs(game:GetChildren()) do
				pcall(function()
					table.insert(list, {service.ClassName, service.Name})
				end)
			end
			
			service = chain:Node("ListNode"):Set({
				title = "Search for object(s) in";
				placeholder = "enter service name...";
				list = list;
			}):Get()
			if not service then return end
			
			if service == "game" then
				service = game	
			else
				service = game:GetService(service)
			end
		end
		
		
		--Get selection
		local selection
		if selectionType == "n" then
			local name, ignoreCase = chain:Node("InputNode"):Set({
				title = "Select object(s) by name";
				placeholder = "enter name...";
			}):Get()
			if not name then return end
			
			local toSet = {}
			for _, obj in ipairs(service:GetDescendants()) do
				if (string.lower(obj.Name) == string.lower(name) and ignoreCase) or (not ignoreCase and obj.Name == name) then
					table.insert(toSet, obj)
				end
			end
			selectionService:Set(toSet)
			selection = selectionService:Get()
		else
			selection = selectionService:Get()
		end
		if #selection == 0 then return end

		--Create a new InputNode with optional settings and make sure input was recieved
		local newName, _ = chain:Node("InputNode"):Set({
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
	end;

}
```

<br>

#### Available Nodes:

![image|446x500](https://doy2mn9upadnk.cloudfront.net/uploads/default/original/4X/a/e/3/ae340915ae2a3fe0914c160746a4f62637dbad5e.png)

<br>

### API:

Before starting, remember to stop the thread if the input from any of the nodes is nil.

Note: the IgnoreCase option, for all the Nodes with this feature, gets saved for each individual Node. This is retrieved the next time the same Node is created.

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
--returns an empty table if no objects were selected
--yields until input is given
--nil if no input received
```

<br>

#### InputNode:
```lua
<InputNode> chain:Node("InputNode") --create InputNode

<ListNode> ListNode:Set({
	title = ""; --title of Node, default: ""
	placeholder = ""; --placeholder text of Node, default: "";
	default = ""; --optional value for node, default: "";
	list = {
		{"", false, Color3.fromRGB()} --format: {option name, true to show icon, icon color}
	};
})

<string, boolean> InputNode:Get()
--returns a string inputted by the user and a boolean if IgnoreCase was selected
--yields until input is given
--nil if no input received
```

<br>

#### ChoiceNode:
```lua
<ChoiceNode> chain:Node("ChoiceNode") --create ChoiceNode

<ChoiceNode> ChoiceNode:Set({
	title = ""; --title of Node, default: ""
	text = ""; --text display message, default: ""
		choices = {
			{"", ""} --format: {key, text}
	};
})

<string> ChoiceNode:Get()
--returns a string key indicating which choice was selected
--yields until input is given
--nil if no input received
```

<br>

#### ListNode:
```lua
<ListNode> chain:Node("ListNode") --create ListNode

<ListNode> ListNode:Set({
	title = ""; --title of Node, default: ""

	placeholder = ""; --placeholder text of Node, default: ""
	list = {
			{"", true, Color3.fromRGB()} --format: {"key", "icon", "icon color"}
	};
})

<string> ListNode:Get()
--returns a string key indicating which option from the list was selected
--yields until input is given
--nil if no input received
```
