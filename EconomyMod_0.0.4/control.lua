require("code.ordering")

-- item_order: # = item.name
if not item_order then item_order = {} end
-- frame_name: variable to hold name of next print label for debug_messages
if not frame_name then frame_name = 0 end
-- market: item.name = price, velocity, min, max,{producer, {ingredient.name, # required}, # produced, weight, time} or constant
if not market then market = {} end
-- constants: item.name = #
if not constants then constants = {
	"iron-ore" = 1,
	"copper-ore" = 1,
	"coal" = 1,
	"stone" = 1,
	"raw-wood" = 1,
	"uranium-ore" = 1,
	"water" = 1,
	"crude-oil" = 1
	}
end
-- debug_messages: # = "Message"
if not debug_messages then debug_messages = {} end

script.on_init(init)

script.on_configuration_changed(init)

function init()
	build_order()
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
	local main_frame = player.gui.center.add({type = "frame", name = "test", direction = "vertical"})
	local frame = main_frame.add({type = "scroll-pane", name = "test-scroll", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	local debuggery = main_frame.add({type = "scroll-pane", name = "debuggery", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	
	debug_messages = {}
	build_eco()
	
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

function build_eco()
	-- recipes: recipe.name = producer, {ingredients or {ingredient, amount}}, {products or {product, amount}}, tech_tier, energy
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
	
	for __, item in pairs(item_order) do
		if constants[item] then
			market[item] = {0, 0, 0, 0, constants[item]}
		else
			market[item] = {0, 0, 0, 0, {}}
		end
	end
	
	---[[
	if table.count(recipes) > 0 then
		for name, recipe in pairs(recipes) do
			local cap = name .. ": " .. table.tostring(recipe)
			debuggery(cap)
		end
	end --]]
	if table.count(tech_order) > 0 then
		for __, tech in pairs(tech_order) do
			debuggery(table.tostring(tech))
		end
	end
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
					table.insert(crafting_cats[category], {entity.name, entity.crafting_speed, (entity.max_energy_usage / (50/3) * 1000)})
				end
			end
		end
	end
	
	-- order crafters based on crafting speed, low to high
	for category, entities in pairs(crafting_cats) do
		if table.count(entities) >= 2 then
			for i=1, table.count(entities) do
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
	
	-- market_recipes: recipe.name = {{producer.name, producer.crafting_speed, energy_consumption (watts), {ingredients or {ingredient, amount}}, {products or {product, amount}}, tech_tier, energy}
	local market_recipes = {}
	
	for __, recipe in pairs(game.recipe_prototypes) do 
		local ingredients = {}
		
		for __, ingredient in pairs(recipe.ingredients) do
			table.insert(ingredients, {ingredient.name, ingredient.amount})
		end
		
		local products = {}
		
		for __, product in pairs(recipe.products) do
			table.insert(products, {product.name, product.amount})
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