-- Order all items
function build_order()
	item_order = {}
	
	-- orderer: product.name = {{ingredients}, is_ordered}
	local orderer = {}
	-- items: {item.name}
	local items = {}
	for __, item in pairs(game.item_prototypes) do
		if not item.has_flag("hidden") then
			if not orderer[item.name] then
				orderer[item.name] = {{}, false}
			end
			table.insert(items, item.name)
			if item.burnt_result then
				if orderer[item.burnt_result.name] then
					table.insert(orderer[item.burnt_result][1], {item.name})
				else
					orderer[item.burnt_result.name] = {{{item.name}}, false}
				end
			end
		end
	end
	
	for __, fluid in pairs(game.fluid_prototypes) do
		orderer[fluid.name] = {{}, false}
		table.insert(items, fluid.name)
	end
	
	-- For each recipe...
	for __, recipe in pairs(game.recipe_prototypes) do
		-- Ingredients for this recipe
		if not is_hidden(orderer, recipe) then
		
			local ingredients = {}
		
			-- For each ingredient in recipe...
			for __, ingredient in pairs(recipe.ingredients) do
				-- Add to table of ingredients
				table.insert(ingredients, ingredient.name)
			end
			
			-- For each product in recipe...
			for __, product in pairs(recipe.products) do
				--print_in_debuggery((product.name .. "-barrel"))
				--print_in_debuggery(ingredients[1])
				if orderer[product.name] and not (ingredients[1] == (product.name .. "-barrel"))then
					--print_in_debuggery(product.name)
					-- Add ingredients to products's ingredients
					table.insert(orderer[product.name][1], ingredients)
				end
			end
		end
	end
	
	order(items, orderer)
end

-- Create the update order
function order(items, orderer)
	--local debugg = 100
	--local debugg2 = 5
	
	--for j=1, debugg do
	while table.count(items) > 0 do
		for i=table.count(items), 1, -1 do
			if can_be_ordered(orderer, orderer[items[i]]) then--, debuggery) then
				orderer[items[i]][2] = true
				table.insert(item_order, items[i])
				table.remove(items, i)
			end
			--if items[i] == "crude-oil" then
			--	print_in_debuggery("crude-oil: " .. table.tostring(orderer[items[i]])})
			--elseif items[i] == "water" then
			--	print_in_debuggery("water: " .. table.tostring(orderer[items[i]]))
			--end
		end
		
		local cap = ""
		for __, item in pairs(items) do
			cap = cap .. item .. ", "
		end
		
		debuggery(cap)
	end
end

-- Check if all ingredients of any recipe are in item_order
function can_be_ordered(orderer, to_be_ordered)	
	if table.count(to_be_ordered[1]) == 0 then
		return true
	end
	
	for __, ingredients in pairs(to_be_ordered[1]) do
		if ingredient_check(orderer, ingredients) then
			return true
		end
	end
	
	return false
end

-- Check if all ingredients in a recipe are in item_order
function ingredient_check(orderer, ingredients)
	for __, ingredient in pairs(ingredients) do
		if not orderer[ingredient][2] then
			return false
		end
	end
	return true
end

-- Check if a product is not in the orderer
function is_hidden(orderer, recipe)
	for __, product in pairs(recipe.products) do
		if orderer[product.name] then
			return false
		end
	end
	return true
end