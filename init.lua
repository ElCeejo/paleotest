paleotest = {}

paleotest.mobkit_mobs = {}
paleotest.global_walkable = {}
paleotest.global_flora = {}
paleotest.global_leaves = {}
paleotest.global_plants = {}
paleotest.global_liquid = {}

minetest.register_on_mods_loaded(function()
	-- Entities
    for name in pairs(minetest.registered_entities) do
        local mob = minetest.registered_entities[name]
        if mob.get_staticdata == mobkit.statfunc
        and (mob.logic or mob.brainfunc) then
            table.insert(paleotest.mobkit_mobs, name)
        end
	end
	-- Nodes
	for name in pairs(minetest.registered_nodes) do
		if name ~= "air" and name ~= "ignore" then
			if minetest.registered_nodes[name].walkable then
				table.insert(paleotest.global_walkable, name)
			end
			if minetest.registered_nodes[name].groups.flora then
				table.insert(paleotest.global_flora, name)
				table.insert(paleotest.global_plants, name)
			end
			if minetest.registered_nodes[name].groups.leaves then
				table.insert(paleotest.global_leaves, name)
				table.insert(paleotest.global_plants, name)
			end
			if minetest.registered_nodes[name].drawtype == "liquid" then
				table.insert(paleotest.global_liquid, name)
			end
		end
	end
end)

paleotest.global_meat = {}

local common_meat_names = {
	"beef",
	"chicken",
	"mutton",
	"porkchop",
	"meat"
}

minetest.register_on_mods_loaded(function()
	for name in pairs(minetest.registered_items) do
		for _,i in ipairs(common_meat_names) do
			if (name:match(i)
			and (name:match("raw") or name:match("uncooked")))
			or minetest.registered_items[name].groups.food_meat_raw then
				table.insert(paleotest.global_meat, name)
			end
		end
	end
end)

paleotest.global_fish = {}

local common_fish_names = {
	"fish",
	"cod",
	"bass",
	"tuna",
	"salmon"
}

minetest.register_on_mods_loaded(function()
	for name in pairs(minetest.registered_items) do
		for _, i in ipairs(common_fish_names) do
			if name:find(i)
			and (name:find("raw")
			or name:find("uncooked"))
			or name:find("cooked") then
				table.insert(paleotest.global_fish, name)
			end
		end
	end
end)

function paleotest.remove_string(tbl, val)
    for i, v in ipairs(tbl) do
    if v == val then
        return table.remove(tbl, i)
        end
    end
end

function paleotest.find_string(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

local path = minetest.get_modpath("paleotest")

-- API
dofile(path.."/api/api.lua")
dofile(path.."/api/hq_lq.lua")
dofile(path.."/api/register.lua")
if minetest.settings:get_bool("legacy_convert") then
	dofile(path.."/legacy_convert.lua")
end

-- Items
dofile(path.."/nodes.lua")
dofile(path.."/craftitems.lua")
dofile(path.."/crafting.lua")
dofile(path.."/ores.lua")
dofile(path.."/fossil_analyzer.lua")
dofile(path.."/dna_cultivator.lua")
dofile(path.."/feeders.lua")


-- Dinosaurs

dofile(path.."/mobs/brachiosaurus.lua")
dofile(path.."/mobs/carnotaurus.lua")
dofile(path.."/mobs/stegosaurus.lua")
dofile(path.."/mobs/spinosaurus.lua")
dofile(path.."/mobs/triceratops.lua")
dofile(path.."/mobs/tyrannosaurus.lua")
dofile(path.."/mobs/velociraptor.lua")

-- Reptiles
dofile(path.."/mobs/pteranodon.lua")
dofile(path.."/mobs/quetzalcoatlus.lua")
dofile(path.."/mobs/sarcosuchus.lua")

-- Aquatic Mobs
dofile(path.."/mobs/dunkleosteus.lua")
dofile(path.."/mobs/mosasaurus.lua")
dofile(path.."/mobs/plesiosaurus.lua")

-- Mammals
dofile(path.."/mobs/dire_wolf.lua")
dofile(path.."/mobs/elasmotherium.lua")
dofile(path.."/mobs/mammoth.lua")
dofile(path.."/mobs/procoptodon.lua")
dofile(path.."/mobs/smilodon.lua")
dofile(path.."/mobs/thylacoleo.lua")

if minetest.settings:get_bool('spawning') then
	dofile(path.."/spawning.lua")
end

minetest.log("action", "[MOD] PaleoTest v2.0 Dev loaded")
