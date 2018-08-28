require("prototypes.entity")

data:extend({
	{
    type = "custom-input",
    name = "Eco",
    key_sequence = "SHIFT + R",
    consuming = "script-only"
	}
})

data.raw["gui-style"]["default"]["test-style"] =
{
	type = "scroll_pane_style",
	maximal_height = 500,
	maximal_width = 500
}

data.raw["gui-style"]["default"]["debuggery"] = 
{
	width = 500
}