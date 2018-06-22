local fastBeltTech = data.raw.technology["logistics-2"]
local expressBeltTech = data.raw.technology["logistics-3"]
local railSystemTech = data.raw.technology["rail-signals"]
table.insert(fastBeltTech.effects, {type = "unlock-recipe", recipe = "fast-portal-belt"})
table.insert(expressBeltTech.effects, {type = "unlock-recipe", recipe = "express-portal-belt"})
table.insert(railSystemTech.effects, {type = "unlock-recipe", recipe = "rail-portal"})

data:extend({
{
	type = "technology",
	name = "marcet",
	icon = "__EconomyMod__/graphics/icon/market.png",
	icon_size = 32,
	prerequisites = {"electronics", "logistics"},
	unit =
	{
		count = 25,
		ingredients = {{"science-pack-1", 1}, {"science-pack-2", 1}},
		time = 10,
	},
	effects = 
	{
		{type = "unlock-recipe", recipe = "marcet"}
	},
},
{
	type = "technology",
	name = "portals",
	icon = "__EconomyMod__/graphics/icon/market.png",
	icon_size = 32,
	prerequisites = {"marcet"},
	unit = 
	{
		count = 25,
		ingredients = {{"science-pack-1", 1}, {"science-pack-2", 1}},
		time = 15,
	},
	effects = 
	{
		{type = "unlock-recipe", recipe = "portal-piece"},
		{type = "unlock-recipe", recipe = "portal"},
		{type = "unlock-recipe", recipe = "portal-belt"}
	},
}
})