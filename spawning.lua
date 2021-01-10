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
        brachiosaurus = {intrvl = 50, chance = 0.5, biomes = {unpack(shoresbiomes), unpack(otherbiomes)}, near = {'default:dirt_with_grass','default:river_water_source'}},
        carnotaurus = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        dire_wolf = {intrvl = 5, chance = 0.4, group = 10, biomes = forestbiomes, near = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
        dunkleosteus = {intrvl = 50, chance = 0.5, biomes = oceanbiomes, near = {'default:water_source'}},
        elasmotherium = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}}, --unicorn!
        mammoth = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass','default:snowblock','default:ice','default:dirt_with_snow','default:permafrost_with_stones'}},
        mosasaurus = {intrvl = 50, chance = 0.5, biomes = oceanbiomes, near = {'default:water_source'}},
        plesiosaurus = {intrvl = 50, chance = 0.5, biomes = oceanbiomes, near = {'default:water_source'}},
        procoptodon = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        pteranodon = {intrvl = 50, chance = 0.5, biomes = highlandbiomes, near = {'default:dirt_with_grass'}},
        quetzalcoatlus = {intrvl = 50, chance = 0.5, biomes = highlandbiomes, near = {'default:dirt_with_grass'}},
        sarcosuchus = {intrvl = 50, chance = 0.5, biomes = shoresbiomes, near = {'default:river_water_source','default:sand'}},
        smilodon = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        spinosaurus = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        stegosaurus = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        thylacoleo = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        triceratops = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        tyrannosaurus = {intrvl = 50, chance = 0.5, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        velociraptor = {intrvl = 5, chance = 0.4, group = 10, biomes = forestbiomes, near = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
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
    -- local radius = 32
    for mob, def in pairs(mob_list) do
        local spawn_timer = 0
        minetest.register_globalstep(function(dtime)
            spawn_timer = spawn_timer + dtime
            if spawn_timer > def.intrvl then
                if math.random(1, def.chance) == 1 then
                    -- local pos = mobkit.get_spawn_pos_abr(1, 1, 1, 1, 0)
                    -- local pos1 = {x=pos.x + 32, y=pos.y + 32, z=pos.z + 32}
                    -- local pos2 = {x=pos.x - 32, y=pos.y - 32, z=pos.z - 32}
                    -- local nodes = minetest.find_nodes_in_area_under_air(pos1, pos2, nodenames)
                    mob_core.spawn("paleotest:"..mob, {"group:soil", "group:stone"}, 0, minetest.LIGHT_MAX, -31000, 31000, 24, 256, def.group or 1, {biomes = def.biomes})
                end
                spawn_timer = 0
            end
        end)
        -- mob_core.register_spawn({name = "paleotest:"..mob, nodes = def.near}, def.intrvl, def.chance)
    end

    -- local radius = 32 -- I expect the radius to be the same for every mob, if not we can add it as an item in the mob definitions array above, which would be accessed below as def.radius
    -- minetest.register_globalstep(function(dtime)
    --     for mob, def in pairs(mob_list) do
    --         local spawnpos = mobkit.get_spawn_pos_abr(dtime, def.intrvl, radius, def.chance, def.reduction)
    --         if spawnpos then
    --             local biome = minetest.get_biome_data(spawnpos)
    --             -- minetest.log('action', 'Checking if mob can spawn in '..dump(biome))
    --             if has_value(def.biomes, minetest.get_biome_name(biome.biome)) then
    --                 -- minetest.log("action", "[MOD] PaleoTest spawning mob "..mob)
    --                 local newmob = minetest.add_entity(spawnpos, "paleotest:"..mob)
    --                 minetest.log("action", "[MOD] PaleoTest spawning mob "..dump(newmob))
    --                 -- newmob.on_activate(newmob)
    --             end
    --         end
    --     end
    -- end)
end)
