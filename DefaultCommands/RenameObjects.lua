local changeHistoryService = game:GetService("ChangeHistoryService")
local selectionService = game:GetService("Selection")

return {

	metadata = {
		id = "DefaultCMD:RenameObjects";   --unique id for every command
		display = "Rename object(s)";   --display-text for command
		shortcut = {Enum.KeyCode.LeftShift, Enum.KeyCode.R}; --optional shortcut
		inputRequired = true;   --enable if command requires input
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