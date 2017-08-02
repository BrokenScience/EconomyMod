require("code.ordering")

-- item_order: {item.name}
if not item_order then item_order = {} end
-- frame_name: variable to hold name of next print label in debuggery
if not frame_name then frame_name = 0 end
-- market: item.name = {{producer, constant, {ingredient.name, # required}, # produced, weight, time}, price, velocity}
if not market then market = {} end

script.on_init(build_orderer)

script.on_configuration_changed(build_orderer)

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
	
	for __, recipe in pairs(game.recipe_prototypes) do
		frame.add({type = "label", name = next_name(), caption = table.tostring(recipe)})
	end
	
	--for __, item in pairs(item_order) do
	--	frame.add({type = "label", name = next_name(), caption = item})
	--end
	
	--frame.add({type = "label", name = next_name(), caption = table.count(item_order)})
end

function update_prices()
	
end

-- Count the number of items in table (-1 if not a table)
function table.count(t)
	if not (type(t) == "table") then	
		return -1
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