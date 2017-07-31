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
	maximal_height = 400,
	maximal_width = 250
}