frame_name = 0;

-- Get next name
function next_name()
	frame_name = frame_name + 1
	return tostring(frame_name)
end