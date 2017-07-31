if not item_order then item_order = {} end
if not frame_name then frame_name = 0 end

-- Test gui control
script.on_event("Eco", function(event)
	local player = game.players[event.player_index]
	
	if player.gui.center.test then
		player.gui.center.test.destroy()
		item_order = {}
	else
		test_open(player)
	end
end)

-- Opens test gui
function test_open(player)
	frame_name = 0
	local main_frame = player.gui.center.add({type = "frame", name = "test", direction = "vertical"})
	local frame = main_frame.add({type = "scroll-pane", name = "test-scroll", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	local debuggery = main_frame.add({type = "scroll-pane", name = "debuggery", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	-- inout: {{ingredients}, {products}}
	local inout = {}
	
	local items, orderer = build_orderer(debuggery)
	order(items, orderer, debuggery)
	
	--local count = table.count(item_order)
	
	--for i=1, count do
	--	frame.add({type = "label", name = next_name(), caption = item_order[i]})
	--end
	
	--frame.add({type = "label", name = next_name(), caption = count})
end

-- Order all items
function build_orderer(debuggery)
	-- orderer: product.name = {{ingredients}, is_ordered}
	local orderer = {}
	local items = {}
	for __, item in pairs(game.item_prototypes) do
		if not item.has_flag("hidden") then
			orderer[item.name] = {{}, false}
			table.insert(items, item.name)
		end
	end
	
	for __, fluid in pairs(game.fluid_prototypes) do
		orderer[fluid.name] = {{}, false}
		table.insert(items, fluid.name)
	end
	
	-- For each recipe...
	for __, recipe in pairs(game.recipe_prototypes) do
		-- Ingredients for this recipe
		if not is_hidden(orderer, recipe) then
		
			local ingredients = {}
		
			-- For each ingredient...
			for __, ingredient in pairs(recipe.ingredients) do
				-- Add to table of ingredients
				table.insert(ingredients, ingredient.name)
			end
			
			-- For each product...
			for __, product in pairs(recipe.products) do
				--debuggery.add({type = "label", name = next_name(), caption = (product.name .. "-barrel")})
				if orderer[product.name] and not ingredients[1] == (product.name .. "-barrel")then
					-- Add recipe ingredients to products's ingredients
					table.insert(orderer[product.name][1], ingredients)
				end
			end
		end
	end
	
	return items, orderer
end

-- Create the update order
function order(items, orderer, debuggery)
	local debugg = 1
	--local debugg2 = 5
	
	for j=1, debugg do
	--while table.count(items) > 0 do
		for i=table.count(items), 1, -1 do
			if can_be_ordered(orderer, orderer[items[i]], debuggery) then
				orderer[items[i]][2] = true
				table.insert(item_order, items[i])
				table.remove(items, i)
			end
			if items[i] == "crude-oil" then
				debuggery.add({type = "label", name = next_name(), caption = "crude-oil: " .. table.tostring(orderer[items[i]])})
			elseif items[i] == "water" then
				debuggery.add({type = "label", name = next_name(), caption = "water: " .. table.tostring(orderer[items[i]])})
			end
		end
		
		local cap = ""
		for __, item in pairs(items) do
			cap = cap .. item .. ", "
		end
		
		debuggery.add({type = "label", name = next_name(), caption = cap})
	end
end

function can_be_ordered(orderer, to_be_ordered, debuggery)	
	if table.count(to_be_ordered[1]) == 0 then
		return true
	end
	
	for __, ingredients in pairs(to_be_ordered[1]) do
		if ingredient_check(orderer, ingredients) then
			return true
		end
	end
	
	return false
end

function ingredient_check(orderer, ingredients)
	for __, ingredient in pairs(ingredients) do
		if not orderer[ingredient][2] then
			return false
		end
	end
	return true
end

-- Check if any product is in the orderer
function is_hidden(orderer, recipe)
	for __, product in pairs(recipe.products) do
		if orderer[product.name] then
			return false
		end
	end
	return true
end

-- Count the number of items in table
function table.count(t)
	local count = 0
	for a, b in pairs(t) do
		count = count + 1
	end
	return count
end

-- Check if a table contains a value
function table.contains_value(t, value)
	for __, val in pairs(t) do
		if val == value then
			return true
		end
	end
	return false
end

-- Get next name
function next_name()
	frame_name = frame_name + 1
	return frame_name
end

-- debug: table to readable string (found at http://lua-users.org/wiki/TableUtils )
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end