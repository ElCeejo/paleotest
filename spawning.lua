minetest.register_on_mapgen_init(function()
    local allbiomes = {}
    local oceanbiomes = {}
    local shoresbiomes = {}
    local forestbiomes = {}
    local otherbiomes = {}
    local desertbiomes = {}
    local highlandbiomes = {}
    for biome, entry in pairs(minetest.registered_biomes) do
        -- minetest.log('debug', '[paleotest] Discovered biome named '..biome)
        table.insert(allbiomes, biome)
        if string.find(biome, 'ocean') then
            table.insert(oceanbiomes, biome)
        elseif string.find(biome, 'shore') or string.find(biome, 'dune') then
            table.insert(shoresbiomes, biome)
        elseif string.find(biome, 'highland') then
            table.insert(highlandbiomes, biome)
        elseif string.find(biome, 'under') then
            -- skip, no mobs spawn here
        elseif string.find(biome, 'forest') then
            table.insert(forestbiomes, biome)
        elseif string.find(biome, 'desert') then
            table.insert(desertbiomes, biome)
        else
            table.insert(otherbiomes, biome)
        end
    end
    -- minetest.log("debug", "[MOD] PaleoTest found these "..table.getn(allbiomes).." biomes "..dump(allbiomes))
    local mob_list = {
        -- create item for every mob with fine tuned settings here
        brachiosaurus = {intrvl = 5, chance = 0.5, biomes = {unpack(shoresbiomes), unpack(otherbiomes)}, near = {'default:dirt_with_grass','default:river_water_source'}},
        carnotaurus = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        dire_wolf = {intrvl = 1, chance = 0.4, group = 10, biomes = forestbiomes, near = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
        dunkleosteus = {intrvl = 5, chance = 0.5, biomes = oceanbiomes, near = {'default:water_source'}},
        elasmotherium = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}}, --unicorn!
        mammoth = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass','default:snowblock','default:ice','default:dirt_with_snow','default:permafrost_with_stones'}},
        mosasaurus = {intrvl = 5, chance = 0.5, biomes = oceanbiomes, near = {'default:water_source'}},
        plesiosaurus = {intrvl = 5, chance = 0.5, biomes = oceanbiomes, near = {'default:water_source'}},
        procoptodon = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        pteranodon = {intrvl = 5, chance = 0.5, biomes = highlandbiomes, near = {'default:dirt_with_grass'}},
        quetzalcoatlus = {intrvl = 5, chance = 0.5, biomes = highlandbiomes, near = {'default:dirt_with_grass'}},
        sarcosuchus = {intrvl = 5, chance = 0.5, biomes = shoresbiomes, near = {'default:river_water_source','default:sand'}},
        smilodon = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        spinosaurus = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        stegosaurus = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        thylacoleo = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        triceratops = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        tyrannosaurus = {intrvl = 5, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        velociraptor = {intrvl = 1, chance = 0.4, group = 10, biomes = forestbiomes, near = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
    }
    -- after defining these mobs, we can add mod dependant materials to the near array like this:
    -- if minetest.get_modpath('ethereal') then
        -- table.insert(mob_list.tyrannosaurus.biomes, 'mushroom')
    -- end

    local function has_value (tab, val)
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end

        return false
    end
    for mob, def in pairs(mob_list) do
        local spawn_timer = 0
        minetest.register_globalstep(function(dtime)
            spawn_timer = spawn_timer + dtime
            if spawn_timer > def.intrvl then
                if math.random(1, def.chance) == 1 then
                    mob_core.spawn("paleotest:"..mob, {"group:soil", "group:stone"}, 0, minetest.LIGHT_MAX, -31000, 31000, 24, 256, def.group or 1, {biomes = def.biomes})
                end
                spawn_timer = 0
            end
        end)
        -- mob_core.register_spawn({name = "paleotest:"..mob, nodes = def.near, optional = {biomes = def.biomes}}, def.intrvl, def.chance)
    end
end)
