local changeHistoryService = game:GetService("ChangeHistoryService")

return {

	metadata = {
		id = "DefaultCMD:RenameObjects";   --unique id for every command
		display = "Rename object(s)";   --display-text for command
		inputRequired = true;   --enable if command requires input
	};

	execute = function(chain)

		--Create a new SelectionNode with optional settings and make sure input was recieved
		local selection, _ = chain:Node("SelectionNode"):Set({
			title = "Select object(s)";
		}):Get()
		if not selection or #selection < 1 then chain:Dispose() return end


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

		--Close Chain after use
		chain:Dispose()

	end;

}