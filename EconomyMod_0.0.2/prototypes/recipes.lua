data:extend(
{
	{
		type = "recipe",
		name = "marcet",
		enabled = false,
		ingredients = 
		{
			{"electronic-circuit", 20},
			{"iron-plate", 100},
			{"copper-cable", 50},
		},
		energy_required = 15,
		result = "marcet",
	},
	{
		type = "recipe",
		name = "portal-piece",
		enabled = false,
		ingredients =
		{
			{"copper-cable", 20},
			{"iron-plate", 10},
			{"electronic-circuit", 10},
		},
		result = "portal-piece",
	},
	{
		type = "recipe",
		name = "portal",
		enabled = false,
		ingredients = 
		{
			{"portal-piece", 5},
			{"iron-plate", 25},
			{"electronic-circuit", 10},
		},
		energy_required = 1,
		result = "portal",
	},
	{
		type = "recipe",
		name = "portal-belt",
		enabled = false,
		ingredients = 
		{
			{"portal", 1},
			{"transport-belt", 1},
			{"iron-plate", 10},
			{"electronic-circuit", 5},
		},
		energy_required = 5,
		result = "portal-belt",
	},
	{
		type = "recipe",
		name = "fast-portal-belt",
		enabled = false,
		ingredients = 
		{
			{"portal", 1},
			{"fast-transport-belt", 1},
			{"iron-plate", 20},
			{"electronic-circuit", 10},
		},
		energy_required = 5,
		result = "fast-portal-belt",
	},
	{
		type = "recipe",
		name = "express-portal-belt",
		enabled = false,
		ingredients = 
		{
			{"portal", 1},
			{"express-transport-belt", 1},
			{"steel-plate", 10},
			{"electronic-circuit", 20},
		},
		energy_required = 5,
		result = "express-portal-belt",
	},
	{
		type = "recipe",
		name = "rail-portal",
		enabled = false,
		ingredients = 
		{
			{"portal", 4},
			{"rail", 2},
			{"steel-plate", 50},
			{"electronic-circuit", 50},
		},
		energy_required = 10,
		result = "rail-portal",
	}
}
)