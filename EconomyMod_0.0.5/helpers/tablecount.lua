-- Count the number of items in table (0 if not a table)
function table.count(t)
	local count = 0
	if (type(t) == "table") then	
		for k, v in pairs(t) do
			count = count + 1
		end
	end
	return count
end