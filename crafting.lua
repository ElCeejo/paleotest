-----------------------
-- Craftting Recipes --
-----------------------
------- Ver 2.0 -------

--------------
-- Crafting --
--------------

minetest.register_craft({
	output = "paleotest:feeder_carnivore",
	recipe = {
		{"group:color_red", "default:glass", "group:color_red"},
		{"", "bucket:bucket_empty", ""},
		{"", "default:steelblock", ""},
	}
})

minetest.register_craft({
	output = "paleotest:feeder_piscivore",
	recipe = {
		{"group:color_blue", "default:glass", "group:color_blue"},
		{"", "bucket:bucket_empty", ""},
		{"", "default:steelblock", ""},
	}
})

minetest.register_craft({
	output = "paleotest:feeder_herbivore",
	recipe = {
		{"group:color_green", "default:glass", "group:color_green"},
		{"", "bucket:bucket_empty", ""},
		{"", "default:steelblock", ""},
	}
})

minetest.register_craft({
	output = "paleotest:field_guide",
	recipe = {
		{"", "", ""},
		{"group:fossil", "", ""},
		{"default:book", "group:color_blue", ""},
	}
})

minetest.register_craft({
	output = "paleotest:whip",
	recipe = {
		{"", "", "farming:cotton"},
		{"", "default:stick", "farming:cotton"},
		{"default:stick", "", "farming:cotton"},
	}
})


minetest.register_craft({
	output = "paleotest:pursuit_ball",
	recipe = {
		{"farming:string", "wool:pink", "farming:string"},
		{"wool:pink", "farming:cotton", "wool:pink"},
		{"farming:string", "wool:pink", "farming:string"},
	}
})

minetest.register_craft({
	output = "paleotest:scratching_post",
	recipe = {
		{"wool:white", "default:wood", "wool:white"},
		{"wool:white", "default:wood", "wool:white"},
		{"default:tree", "default:tree", "default:tree"},
	}
})

minetest.register_craft({
    output = "paleotest:dna_cultivator",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:glass", "bucket:bucket_water", "default:glass"},
        {"default:steel_ingot", "default:bronze_ingot", "default:steel_ingot"}
    }
})

minetest.register_craft({
    output = "paleotest:fossil_analyzer",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:steel_ingot", "default:copper_ingot", "default:steel_ingot"},
        {"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"}
    }
})

minetest.register_craft({
	type = "cooking",
	output = "paleotest:dinosaur_meat_raw",
	recipe = "paleotest:dinosaur_meat_cooked",
	cooktime = 5
})

minetest.register_craft({
	type = "cooking",
	output = "paleotest:mammal_meat_raw",
	recipe = "paleotest:mammal_meat_cooked",
	cooktime = 5
})

minetest.register_craft({
	type = "cooking",
	output = "paleotest:reptile_meat_raw",
	recipe = "paleotest:reptile_meat_cooked",
	cooktime = 5
})

minetest.register_craft({
	type = "cooking",
	output = "paleotest:fish_meat_raw",
	recipe = "paleotest:fish_meat_cooked",
	cooktime = 5
})

