require("code.ordering")

-- item_order: # = item.name
if not item_order then item_order = {} end

-- frame_name: variable to hold name of next print label for debug_messages
if not frame_name then frame_name = 0 end

-- market: item.name = price, velocity, min, max,{producer, {ingredient.name, # required}, # produced, weight, time}, constant, energy_value or nil
if not market then market = {} end

-- resource_constants: item.name = #
if not resource_constants then resource_constants = {
	["energy"] = 1,
	["iron-ore"] = 1,
	["copper-ore"] = 1,
	["coal"] = 1,
	["stone"] = 1,
	["raw-wood"] = 1,
	["uranium-ore"] = 1,
	["water"] = 1,
	["crude-oil"] = 1
	}
end

-- other constants for non-resource things
if not arbitrary_constants then arbitrary_constants = {
	["time"] = 1,
	["ingredients"] = 1.1,
	["location"] = .25,
	["scale"] = 10
	}
end

-- debug_messages: # = "Message"
if not debug_messages then debug_messages = {} end

script.on_init(init)

script.on_configuration_changed(init)

function init()
	math.randomseed(os.time())
	--build_order()
	--build_eco()
end

-- Test gui control
script.on_event("Eco", function(event)
	local player = game.players[event.player_index]
	if player.gui.center.test then
		player.gui.center.test.destroy()
	else
		test_open(player)
	end
end)

-- Opens test gui
function test_open(player)
	local main_frame = player.gui.center.add({type = "frame", name = "test", direction = "vertical", style = "debuggery"})
	local frame = main_frame.add({type = "scroll-pane", name = "test-scroll", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	local debuggery = main_frame.add({type = "scroll-pane", name = "debuggery", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	
	debug_messages = {}
	build_order()
	--build_eco()
	--other()
	
	
	if table.count(debug_messages) > 0 then
	debuggery.add({type = "label", name = next_name(), caption = table.count(debug_messages)})
		for __, message in pairs(debug_messages) do
			debuggery.add({type = "label", name = next_name(), caption = message})
		end
	end
	
	for __, item in pairs(item_order) do
		frame.add({type = "label", name = next_name(), caption = item})
	end
	
	--frame.add({type = "label", name = next_name(), caption = table.count(item_order)})
end

function other()
	for name, entity in pairs(game.entity_prototypes) do
		local cap = name
		if entity.mineable_properties then
			if entity.mineable_properties.fluid_amount then
				cap = cap .. "; " .. entity.mineable_properties.required_fluid .. ": " .. entity.mineable_properties.fluid_amount .. "; " .. entity.mineable_properties.mining_time .. "; "
				for __, product in pairs(entity.mineable_properties.products) do
					cap = cap .. product.name .. ": " .. product.amount
				end
				debuggery(cap)
			end
		end
	end
end

function build_eco()
	-- recipes: recipe.name = producer, {ingredients or {ingredient, amount}}, {products or {product, amount, combo_coefficient}}, tech_tier, time
	local recipes = link_recipe_categories()
	-- tech_order: # = tech
	local tech_order = order_tech()
	
	-- Assign tech_tier
	for i=1, table.count(tech_order) do
		for __, modifier in pairs(tech_order[i].effects) do
			if modifier.type == "unlock-recipe" then
				recipes[modifier.recipe][4] = i + 1
			end
		end
	end
	
	-- Add energy to market
	market["energy"] = {0, 0, 0, 0, {}, nil}
	
	-- Add all items to market
	for __, item in pairs(game.item_prototypes) do
		if not item.has_flag("hidden") then
			market[item.name] = {0, 0, 0, 0, {}, item.fuel_value}
		end
	end
	
	-- Add all recipes to market
	for __, recipe in pairs(recipes) do
		for __, product in pairs(recipe[3]) do
			-- Clear all other products out from recipe
			-- simplified_recipe: # = producer, {ingredient, amount}, # produced, tech_tier, combo_coefficient, time
			local simplified_recipe = recipe
			simplified_recipe[3] = product[2]
			table.insert(simplified_recipe, 5, product[3])
			table.insert(market[product[1]][5], simplified_recipe)
		end
	end
	
	-- Insert resource_constants for raw-resources
	for resource, constant in pairs(resource_constants) do
		market[resource][5] = constant
	end
	
	-- Determine weights for each recipe in end price
	--(solve (1/tech_level1)X + (1/tech_level2)X + ... + (1/tech_levelN)X = 1 for X, then use X to find the weights (weight = (1/tech_level)X) )
	for __, item in pairs(market) do
		-- If table in recipes section (signaling not a raw-resource)...
		if type(item[5]) == "table" then
			-- weight = sum of tech ratio components
			local weight = 0
			
			-- Change tech_level into the recipe weight coefficient
			for __, recipe in pairs(item[5]) do
				recipe[4] = (1 / recipe[4])
				weight = weight + recipe[4]
			end
			
			-- Convert weight into item's weight coefficient
			weight = 1 / weight
			
			-- 
			for __, recipe in pairs(item[5]) do
				recipe[4] = recipe[5] * recipe[4] * weight
				-- recipe: # = producer, {ingredient, amount}, # produced, recipe_weight, time
				table.remove(recipe, 5)
			end
		end
	end
	
	-- Calculate initial price, velocity, min, and max of each resource in market
	for number, item_name in pairs(item_order) do 
		-- Save market[item_name]
		local item = market[item_name]
		
		-- Calculate price
		for __, recipe in pairs(item[5]) do
			local ing_cost = 0
			for __, ingredient in pairs(recipe[2]) do
				ing_cost = ing_cost + market[ingredient[1]][1] * ingredient[2] * arbitrary_constants.ingredients
			end
			local energy_cost = recipe[1][3] * recipe[5] * market.energy[1]
			local time_cost = recipe[1][2] * recipe[5] * arbitrary_constants.time
			local recipe_cost = (ing_cost + energy_cost + time_cost) * recipe[4] / recipe[3]
			item[1] = item[1] + recipe_cost
		end
		
		item[1] = item[5]
		
		item[1] = item[1] + item[6] * market.energy[1]
	end
		
		
	
	--[[
	if table.count(recipes) > 0 then
		for name, recipe in pairs(recipes) do
			local cap = name .. ": " .. table.tostring(recipe)
			debuggery(cap)
		end
	end --]]
	--[[
	if table.count(tech_order) > 0 then
		for __, tech in pairs(tech_order) do
			debuggery(table.tostring(tech))
		end
	end --]]
end

-- Link each recipe to its appropriate constructor entity
function link_recipe_categories()
	-- crafting_categories: category = entities(lowest to highest crafting_speed)
	local crafting_cats = {}
	
	-- Each entity with a crafting speed is a crafter. Add each crafter to all categories it can craft.
	for __, entity in pairs(game.entity_prototypes) do
		if entity.crafting_speed then
			for category, enabled in pairs(entity.crafting_categories) do
				if enabled then
					if not crafting_cats[category] then
						crafting_cats[category] = {}
					end
					table.insert(crafting_cats[category], {entity.name, entity.crafting_speed, (entity.max_energy_usage / (50/3))})
				end
			end
		end
	end
	
	-- order crafters based on crafting speed, low to high
	for category, entities in pairs(crafting_cats) do
		if table.count(entities) >= 2 then
			for i=2, table.count(entities) do
				for j=i, 2, -1 do
					if entities[j][2] < entities[j-1][2] then
						local temp = entities[j]
						entities[j] = entities[j-1]
						entities[j-1] = temp
					else
						break
					end
				end
			end
		end
	end
	
	-- market_recipes: recipe.name = {{producer.name, producer.crafting_speed, energy_consumption (kilowatts)}, {ingredients or {ingredient, amount}}, {products or {product, amount, combo_coefficient}}, tech_tier, time}
	local market_recipes = {}
	
	for __, recipe in pairs(game.recipe_prototypes) do 
		local ingredients = {}
		
		for __, ingredient in pairs(recipe.ingredients) do
			table.insert(ingredients, {ingredient.name, ingredient.amount})
		end
		
		local products = {}
		
		for i, product in ipairs(recipe.products) do
			table.insert(products, {product.name, product.amount, 1})
		end
		
		-- Deal with multiple products
		if not recipe.products[1].probability == 1 and recipe.products[1].probability then
			
			for i, product in ipairs(recipe.products) do
				products[i][3] = 1 / product.probability - 1
			end
					
		end
		
		-- For recipes with multiple products...
		if table.count(recipe.products) > 1 then
			-- Check if there are any catalysts and deal with them
			for __, ingredient in pairs(ingredients) do
				for __, product in pairs(products) do
					if ingredient[1] == product[1] then
						if product[2] > ingredient[2] then
							product[2] = product[2] - ingredient[2]
							ingredient[2] = 0
						else
							ingredient[2] = ingredient[2] - product[2]
							product[2] = 0
						end
					end
				end			
			end
			
			local combo = 0
			
			-- Calculate total number of all products
			--if (type(products) == "table") then
				debuggery(table.tostring(products))
				
				for __, product in pairs(products) do
					combo = combo + 1 / product[2]
				end
			
				-- Convert to combo multiplier
				combo = 1 / combo
			
				-- Merge with possible probability coefficient
				for __, product in pairs(products) do
					product[3] = product[3] * combo * 1 / product[2]
				end
			--end
		end
		
		
		market_recipes[recipe.name] = {crafting_cats[recipe.category][1], ingredients, products, 1, recipe.energy}
	end
	
	return market_recipes
end

-- Put the techs in order based on pack counts, time, and prerequisites
function order_tech()
	-- order: # = LuaTechnologyPrototype
	local order = {}
	-- techs: LuaTechnologyPrototype.name = {LuaTechnologyPrototype, cost, is_ordered}
	local techs = {}
	
	for k, tech in pairs(game.technology_prototypes) do
		local count = 0
		local amount = 0
		--for __, prerequisite in pairs(tech.prerequisites) do
		--	debuggery(prerequisite.name)
		--end
		
		for __, ingredient in pairs(tech.research_unit_ingredients) do
			count = count + 1
			amount = amount + ingredient.amount
		end
		
		techs[k] = {tech, count * count / amount * tech.research_unit_count * tech.research_unit_energy, false}
		--debuggery(techs[k][2])
	end
	
	local left = table.count(techs)
	--debuggery(tostring(left))

	while left > 0 do
		-- met: # = {value, tech.name}
		local met = {}
		for k, tech in pairs(techs) do
			if not tech[3] then
				if prerequisites_met(techs, tech[1].prerequisites) then
					--debuggery(tech[1].name .. " has prerequisites_met")
					table.insert(met, {tech[2], k})
				end
			end
		end
		-- met = {best.value, best.tech.name}
		met = determine_next_tech(met)
		table.insert(order, techs[met[2]][1])
		techs[met[2]][3] = true
		left = left - 1
	end
	
	return order
end

function prerequisites_met(techs, prerequisites)
	--debuggery(table.tostring(prerequisites))
	if table.count(prerequisites) == 0 then
		return true
	end
	
	for __, prerequisite in pairs(prerequisites) do
		if not techs[prerequisite.name][3] then
			return false
		end
	end
	
	return true
end

function determine_next_tech(met)
	local best = met[1]
	local count = table.count(met)
	
	for i=2, count do
		if met[i][1] < best[1] then
			best = met[i]
		end
	end
	
	return best
end

-- GLOBAL HELPER METHODS

-- Check if 2 tables share a value (giving a value in [3] checks for a specific value)
function table.share_value(t1, t2, value)
	if not type(t1) == "table" or not type(t2) == "table" then
		return false
	end
	
	if value then
		if table.contains_value(t1, value) and table.contains_value(t2, value) then
			return true
		else
			return false
		end
	end
	
	for __, value in pairs(t1) do
		if table.contains_value(t2, value) then
			return true
		end
	end
	
	return false
end

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

-- Check if a table contains a value
function table.contains_value(t, value)
	for __, val in pairs(t) do
		if val == value then
			return true
		end
	end
	return false
end

-- Check if a table contains a key
function table.contains_key(t, key)
	for k, __ in pairs(t) do
		if k == key then
			return true
		end
	end
	return false
end

-- Add a message to the debug print
function debuggery(message)
	table.insert(debug_messages, message)
end

-- Get next name
function next_name()
	frame_name = frame_name + 1
	return tostring(frame_name)
end

-- debug: table to readable string (found at http://lua-users.org/wiki/TableUtils)
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