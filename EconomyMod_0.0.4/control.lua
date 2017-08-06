require("code.ordering")

-- item_order: {item.name}
if not item_order then item_order = {} end
-- frame_name: variable to hold name of next print label in debuggery
if not frame_name then frame_name = 0 end
-- market: item.name = price, velocity, {producer, {ingredient.name, # required}, # produced, weight, time}, constant
if not market then market = {} end
-- debuggery: {type = "label", name = next_name(), caption = "Message Here"}
if not debuggery then debuggery = {} end

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
	local deb = main_frame.add({type = "scroll-pane", name = "debuggery", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	
	debuggery = {}
	build_eco()
	
	deb.add({type = "label", name = next_name(), caption = table.count(debuggery)})
	if table.count(debuggery) > 0 then
		for __, message in pairs(debuggery) do
			deb.add({type = "label", name = next_name(), caption = message})
		end
	end
	
	for __, item in pairs(item_order) do
		frame.add({type = "label", name = next_name(), caption = item})
	end
	
	--frame.add({type = "label", name = next_name(), caption = table.count(item_order)})
end

function build_eco()
	local recipe_categories = link_recipe_categories()
	--local tech_order = order_tech()
	
	if table.count(tech_order) > 0 then
		for __, tech in pairs(tech_order) do
			print_in_debuggery(tech.name)
		end
	end
end

-- Link each recipe to its appropriate constructor entity
function link_recipe_categories()
	-- crafting_categories: category = entities(lowest to highest crafting_speed)
	local crafting_cats = {}
	
	for __, entity in pairs(game.entity_prototypes) do
		if entity.crafting_speed then
			for category, enabled in pairs(entity.crafting_categories) do
				if enabled then
					if not crafting_cats[category] then
						crafting_cats[category] = {}
					end
					table.insert(crafting_cats[category], {entity.name, entity.crafting_speed, entity.max_energy_usage})
				end
			end
		end
	end
	
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
	
	for category, entities in pairs(crafting_cats) do
		local cap = category .. ": "
		for __, entity in pairs(entities) do
			cap = cap .. entity[1] .. ", "
		end
		
		print_in_debuggery(cap)
	end
end

-- Put the techs in order based on pack counts, time, and prerequisites
function order_tech()
	-- order: # = LuaTechnologyPrototype.Name
	local order = {}
	-- techs: LuaTechnologyPrototype.Name = {LuaTechnologyPrototype, cost, is_ordered}
	local techs = {}
	
	for k, tech in pairs(game.technology_prototypes) do
		local count = 0
		local amount = 0
		--for __, prerequisite in pairs(tech.prerequisites) do
		--	print_in_debuggery(prerequisite.name)
		--end
		
		for __, ingredient in pairs(tech.research_unit_ingredients) do
			count = count + 1
			amount = amount + ingredient.amount
		end
		
		techs[k] = {tech, amount / count * tech.research_unit_count * tech.research_unit_energy, false}
		--print_in_debuggery(techs[k][2])
	end
	
	local left = table.count(techs)
	--print_in_debuggery(tostring(left))

	while left > 0 do
		local met = {}
		for k, tech in pairs(techs) do
			if not tech[3] then
				if prerequisites_met(techs, tech[1].prerequisites) then
					--print_in_debuggery(tech[1].name .. " has prerequisites_met")
					table.insert(met, {tech[2], k})
				end
			end
		end
		
		met = determine_next_tech(met)
		table.insert(order, techs[met[2]][1])
		techs[met[2]][3] = true
		left = left - 1
	end
	
	return order
end

function prerequisites_met(techs, prerequisites)
	--print_in_debuggery(table.tostring(prerequisites))
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


-- Count the number of items in table (-1 if not a table)
function table.count(t)
	if not (type(t) == "table") then	
		return 0
	end
	local count = 0
	for k, v in pairs(t) do
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

function print_in_debuggery(message)
	table.insert(debuggery, message)
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