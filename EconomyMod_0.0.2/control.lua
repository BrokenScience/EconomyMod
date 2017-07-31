if not item_order then item_order = {} end
if not frame_name then frame_name = 0 end
if not max_runs then max_runs = 50 end

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
	
	-- Make table of recipes that are not hidden
	for recipe_name, recipe in pairs(game.recipe_prototypes) do
		if recipe.hidden == false then
		--debuggery.add({type = "label", name = next_name, caption = table.tostring({recipe.ingredients, recipe.products})})
		table.insert(inout, {recipe.ingredients, recipe.products})
		end
	end
	
	build_orderer(debuggery)
	
	--local count = table.count(item_order)
	
	--for i=1, count do
	--	frame.add({type = "label", name = next_name(), caption = item_order[i]})
	--end
	
	--frame.add({type = "label", name = next_name(), caption = count})
end

-- Creates the order for updating items
function fill_item_order(inout, debuggery)
	-- raw: {item_names}
	local raw = {}
	
	-- Add all raw resources to table that will serve as the start of order graph
	for __, item in pairs(game.item_prototypes) do
		if not item.has_flag("hidden") and item.subgroup.name == "raw-resource" then
			table.insert(raw, item.name)
		end
	end
	
	--return item_graph
	
	--debuggery.add({type = "label", name = next_name(), caption = raw[1]})
	-- Start the recursive process of creating the update order
	assess_item(item_graph, raw[1], {}, debuggery)
end

-- Order all items
function build_orderer(debuggery)
	-- orderer: product.name = {{ingredients}, is_ordered}
	local orderer = {}
	for __, item in pairs(game.item_prototypes) do
		if not item.has_flag("hidden") then
			orderer[item.name] = {{}, false}
		end
	end
	
	-- For each recipe...
	for __, recipe in pairs(game.recipe_prototypes) do
		-- Ingredients for this recipe
		if not is_hidden(recipe) then
		
			local ingredients = {}
		
			-- For each ingredient...
			for __, ingredient in pairs(inout[i][1]) do
				-- Make sure ingredient exists in graph
				if not orderer[ingredient.name] then
					graph[ingredient.name] = {{{}, {}}, false}
				end
				
				-- Add to table of ingredients
				table.insert(ingredients, ingredient.name)
			end
				
			end
		end
			
		-- For each product...
		for __, product in pairs(inout[i][2]) do
			-- Make sure product exists in graph
			if not graph[product.name] then
				graph[product.name] = {{{}, {}}, false}
			end
			
			-- Add recipe ingredients to product's ingredients
			table.insert(graph[product.name][1][1], ingredients)
		end
	end
	
	return graph
end

-- Check if ingredients are in order
function ingredients_are_ordered(graph, ingredients, debuggery)
	-- For each ingredient...
	for __, ingredient in pairs(ingredients) do
		-- If ingredient is not in order return false
		if not graph[ingredient][2] then
			return false
		end
	end
	
	-- All ingredients are in order
	return true
end

-- Check if any recipe can be ordered
function can_be_ordered(graph, recipes, debuggery)
	-- If there are no recipes, then return true	
	if table.count(recipes) == 0 then
		return true
	end
	
	-- For each recipe...
	for __, recipe in pairs(recipes) do
		-- If recipe can be ordered return true
		if ingredients_are_ordered(graph, recipe) then
			return true
		end
	end
	-- All recipes cannot be orderd
	return false
end

-- Assess this item and put in order
function assess_item(graph, item, avoidances, debuggery)
	if max_runs > 0 then
		max_runs = max_runs - 1
		-- Assess all items below
		move_down(graph, item, avoidances, debuggery)
	
		-- If this item can be put in the order...
		if can_be_ordered(graph, graph[item][1][1], debuggery) then
			-- Mark as ordered, add to item order, and move up
			graph[item][2] = true
			table.insert(item_order, item)
			debuggery.add({type = "label", name = next_name(), caption = "Item ordered: " .. item})
		else
			debuggery.add({type = "label", name = next_name(), caption = "Item not placed: " .. item})
		end
		-- Assess all items above
		move_up(graph, item, avoidances, debuggery)
	end
end

-- Move up in graph from node(item)
function move_up(graph, item, avoidances, debuggery)
	debuggery.add({type = "label", name = next_name(), caption = "move_up from: " .. item})
	if table.count(graph[item][1][2]) ~= 0 then
		for __, product in pairs(graph[item][1][2]) do
			if not (table.contains_value(avoidances, product) or graph[product][2]) then
				debuggery.add({type = "label", name = next_name(), caption = "move_up to: " .. product})
				assess_item(graph, product, avoidances, debuggery)
			else
				if graph[product][2] then
					debuggery.add({type = "label", name = next_name(), caption = product .. " is already ordered"})
				else
					debuggery.add({type = "label", name = next_name(), caption = product .. " is being avoided"})
				end
			end
		end
	else
		--debuggery.add({type = "label", name = next_name(), caption = 
	end
end

-- Move down in graph from node(item)
function move_down(graph, item, avoidances, debuggery)
	debuggery.add({type = "label", name = next_name(), caption = "move_down from: " .. item})
	table.insert(avoidances, item)
	debuggery.add({type = "label", name = next_name(), caption = item .. " added to avoidances"})
	for __, recipe in pairs(graph[item][1][1]) do
			for __, ingredient in pairs(recipe) do
				if not (table.contains_value(avoidances, ingredient) or graph[ingredient][2]) then
					move_down(graph, ingredient, avoidances, debuggery)
				els?fr
					if graph[ingredient][2] then
						debuggery.add({type = "label", name = next_name(), caption = ingredient .. " is already ordered"})
					else
						debuggery.add({type = "label", name = next_name(), caption = ingredient .. " is being avoided"})
					end
				end
			end
		end
	table.remove(avoidances)
	debuggery.add({type = "label", name = next_name(), caption = item .. " removed from avoidances"})
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
	--if frame_name > 100 then frame_name = 0 end
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