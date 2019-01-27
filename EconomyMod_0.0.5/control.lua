require("helpers.helpers")

-- debug_messages: # = "Message"
if not debug_messages then debug_messages = {} end

script.on_init(init)

script.on_configuration_changed(init)

function init()
	--math.randomseed(os.time())
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

function test_open(player)
	-- Set up gui
	local main_frame = player.gui.center.add({type = "frame", name = "test", direction = "vertical", style = "debuggery"})
	local frame = main_frame.add({type = "scroll-pane", name = "test-scroll", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	local debuggery = main_frame.add({type = "scroll-pane", name = "debuggery", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto", style = "test-style"})
	
	-- Add inital start message
	debug_messages = {"start"}
	
	if table.count(debug_messages) > 0 then
	debuggery.add({type = "label", name = next_name(), caption = table.count(debug_messages)})
		for __, message in pairs(debug_messages) do
			debuggery.add({type = "label", name = next_name(), caption = message})
		end
	end
	
	for __, item in pairs(item_order) do
		frame.add({type = "label", name = next_name(), caption = item})
	end
	
	debuggery.add(debug_messages)
end