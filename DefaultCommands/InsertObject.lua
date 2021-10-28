local changeHistoryService = game:GetService("ChangeHistoryService")
local selectionService = game:GetService("Selection")

return {
	
	metadata = {
		id = "DefaultCMD:InsertObject";
		display = "Insert object(s)";
		inputRequired = true;
	};
	
	execute = function(chain)
		
		local objectClass = chain:Node("ListNode"):Set({
			title = "Select class";
			placeholder = "search class...";
			list = {
				{"Other", true, Color3.fromRGB(159, 89, 9)};
				{"Part", true};
				{"Accessory", true};
				{"Animation", true};
				{"Attachment", true};
				{"ClickDetector", true};
				{"Shirt", true};
				{"Pants", true};
				{"Humanoid", true};
				{"Model", true};
				{"Sound", true};
				{"SurfaceGui", true};
			};
		}):Get();
		if not objectClass then return end
		
		if objectClass == "Other" then
			objectClass = chain:Node("InputNode"):Set({
				title = "Other class";
				placeholder = "enter class name...";
				ignoreCase = false;
			}):Get();
			if not objectClass then return end
		end
		
		local objectName = chain:Node("InputNode"):Set({
			title = "Set object(s) name";
			placeholder = "enter object(s) name...";
			ignoreCase = false;
		}):Get()
		if not objectName then return end
		
		local objectAmount = chain:Node("InputNode"):Set({
			title = "Amount of object(s)";
			placeholder = "enter # of objects to create...";
			ignoreCase = false;
		}):Get();
		if not objectAmount then return end
		
		local selection = selectionService:Get()
		local parent = workspace
		if #selection > 0 then
			parent = chain:Node("ChoiceNode"):Set({
				text = "Parent to selected ("..(selection[1].Name)..")?";
				choices = {
					{"Y", "Yes"};
					{"N", "No (parent to workspace)"};
				}
			}):Get()
			if not parent then return end
		else
			local confirmation = chain:Node("ChoiceNode"):Set({
				text = "Set object parent to workspace?";
				choices = {
					{"Y", "Yes"};
					{"N", "No"};
				}
			}):Get()
			if not confirmation or confirmation == "N" then return end
		end
		
		if parent == "Y" then
			parent = selection[1]
		elseif parent == "N" then
			parent = workspace
		end
		
		changeHistoryService:SetWaypoint("Creating Object")
		local created = {}
		local success, err = pcall(function()
			for i = 1, tonumber(objectAmount) do
				local obj = Instance.new(objectClass)
				obj.Parent = parent
				obj.Name = objectName
				table.insert(created, obj)
			end
		end)
		changeHistoryService:SetWaypoint("Created Object")
		
		if not success then
			error(err)
		end
		
		selectionService:Set(created)
	end;
	
}