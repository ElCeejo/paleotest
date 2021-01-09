minetest.register_on_mapgen_init(function()
    local allbiomes = minetest.registered_biomes
    local oceanbiomes = {}
    local shoresbiomes = {}
    local forestbiomes = {}
    local otherbiomes = {}
    local desertbiomes = {}
    local highlandbiomes = {}
    for biome, entry in ipairs(allbiomes) do
        minetest.log('action', '[paleotest] Discovered biome named '..biome)
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
            table.insert(otherbiomes)
        end
    end
    local mob_list = {
        -- create item for every mob with fine tuned settings here
        brachiosaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = {unpack(shoresbiomes), unpack(otherbiomes)}, near = {'default:dirt_with_grass','default:river_water_source'}},
        carnotaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        dire_wolf = {intrvl = 1, chance = 0.7, reduction = 0, biomes = forestbiomes, near = {'default:dirt_with_grass','default:dirt_with_rainforest_litter'}},
        dunkleosteus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = oceanbiomes, near = {'default:water_source'}},
        elasmotherium = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}}, --unicorn!
        mammoth = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass','default:snowblock','default:ice','default:dirt_with_snow','default:permafrost_with_stones'}},
        mosasaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = oceanbiomes, near = {'default:water_source'}},
        plesiosaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = oceanbiomes, near = {'default:water_source'}},
        procoptodon = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        pteranodon = {intrvl = 1, chance = 0.5, reduction = 0, biomes = highlandbiomes, near = {'default:dirt_with_grass'}},
        quetzalcoatlus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = highlandbiomes, near = {'default:dirt_with_grass'}},
        sarcosuchus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = shoresbiomes, near = {'default:river_water_source','default:sand'}},
        smilodon = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        spinosaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        stegosaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        thylacoleo = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        triceratops = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        tyrannosaurus = {intrvl = 1, chance = 0.5, reduction = 0, biomes = otherbiomes, near = {'default:dirt_with_grass'}},
        velociraptor = {intrvl = 1, chance = 0.7, reduction = 0, biomes = forestbiomes, near = {'default:dirt_with_grass','default:dirt_with_dry_grass','default:dry_dirt_with_dry_grass','default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
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

    local radius = 32 -- I expect the radius to be the same for every mob, if not we can add it as an item in the mob definitions array above, which would be accessed below as def.radius
    minetest.register_globalstep(function(dtime)
        for mob, def in ipairs(mob_list) do
            local spawnpos = mobkit.get_spawn_pos_abr(dtime, def.intrvl, radius, def.chance, def.reduction)
            if spawnpos then
                local biome = minetest.get_biome_data(spawnpos)
                if has_value(def.biomes, minetest.get_biome_name(biome.id)) then
                    minetest.add_entity(spawnpos, "paleotest:"..mob)
                end
            end
        end
    end)
end)
