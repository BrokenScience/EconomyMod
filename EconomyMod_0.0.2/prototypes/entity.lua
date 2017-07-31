require("items")
require("itemsubgroups")
require("recipes")
require("technology")

data:extend (
{
	{
		type = "market",
		name = "marcet",
		icon = "__EconomyMod__/graphics/entity/market.png",
		flags = {"placeable-neutral", "player-creation", "placeable-player"},
		minable = {hardness = 0.2, mining_time = 1, result = "marcet"},
		subgroup = "production-machine",
		order = "d-a-a",
		max_health = 150,
		corpse = "big-remnants",
		collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		picture =
		{
			filename = "__EconomyMod__/graphics/entity/market.png",
			width = 156,
			height = 127,
			shift = {0.95, 0.2}
		}
	}
}
)