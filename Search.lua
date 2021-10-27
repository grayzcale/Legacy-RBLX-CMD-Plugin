--[[By: @V3N0M_Z]]

local searcher = {}
searcher.__index = searcher

local function match(text, item)
	local itemTable = string.split(string.lower(item), "")
	local txtIndex = 1
	local matches = 0
	
	for _, char in ipairs(itemTable) do
		if char == string.lower(string.sub(text, txtIndex, txtIndex)) then
			matches += 1
			txtIndex += 1
			if txtIndex > string.len(text) then
				break
			end
		end
	end
	
	if txtIndex < string.len(text) then
		return false
	end
	return matches
end

local function returnHighestMatch(results)
	local highest = -1
	local index
	local highestItem
	for i, result in ipairs(results) do
		local item, matches = table.unpack(result)
		if matches > highest then
			highestItem = item
			highest = matches
			index = i
		end
	end
	return highestItem, index
end

function searcher.new()
	local self = setmetatable({
		_items = {};
	}, searcher)
	return self
end

function searcher:Include(...)
	table.insert(self._items, ...)
end

function searcher:Search(text)
	local results = {}
	for _, item in ipairs(self._items) do
		local m = match(text, item.Display.Text)
		if m then
			table.insert(results, {item, m})
		end
	end
	local filtered = {}
	while #results > 0 do
		local highestItem, index = returnHighestMatch(results)
		table.insert(filtered, highestItem)
		table.remove(results, index)
	end
	return filtered
end

return searcher