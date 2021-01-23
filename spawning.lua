paleotest.spawn_rate = minetest.settings:get('spawn_rate')
paleotest.spawn_chance = minetest.settings:get('spawn_chance') -- decimal value ranging from 0 to 2

minetest.register_on_mapgen_init(function()
    local allbiomes = {}
    local oceanbiomes = {}
    local shoresbiomes = {}
    local forestbiomes = {}
    local otherbiomes = {}
    local desertbiomes = {}
    local highlandbiomes = {}
    local swampbiomes = {}
    local savannabiomes = {}
    for biome, entry in pairs(minetest.registered_biomes) do
        table.insert(allbiomes, biome)
        if string.find(biome, 'ocean') then
            table.insert(oceanbiomes, biome)
        elseif string.find(biome, 'shore') or string.find(biome, 'dune') then
            table.insert(shoresbiomes, biome)
        elseif string.find(biome, 'highland') then
            table.insert(highlandbiomes, biome)
        elseif string.find(biome, 'swamp') then
            table.insert(swampbiomes, biome)
        elseif string.find(biome, 'under') then
            -- skip, no mobs spawn here
        elseif string.find(biome, 'forest') then
            table.insert(forestbiomes, biome)
        elseif string.find(biome, 'savanna') then
            table.insert(savannabiomes, biome)
        elseif string.find(biome, 'desert') then
            table.insert(desertbiomes, biome)
        else
            table.insert(otherbiomes, biome)
        end
    end
    minetest.register_decoration({
        deco_type = "simple",
        decoration = "paleotest:cycad_3",
        place_on = "group:soil",
        fill_ratio = 0.3,
        biomes = {unpack(highlandbiomes), unpack(swampbiomes), unpack(forestbiomes), unpack(desertbiomes), unpack(savannabiomes), unpack(otherbiomes)},
    })
    minetest.register_decoration({
        deco_type = "simple",
        decoration = "paleotest:horsetail_3",
        place_on = {"group:sand","group:soil"},
        fill_ratio = 0.3,
        biomes = {unpack(shoresbiomes), unpack(swampbiomes)},
    })
    local mob_list = {
        -- create item for every mob with fine-tuned settings here
        -- sea monsters
        dunkleosteus = {intrvl = 30, chance = 0.8, group = 4, biomes = oceanbiomes, nodes = {'group:water'}},
        mosasaurus = {intrvl = 30, chance = 0.8, group = 4, biomes = oceanbiomes, nodes = {'group:water'}},
        plesiosaurus = {intrvl = 30, chance = 0.8, group = 4, biomes = oceanbiomes, nodes = {'group:water'}},
        -- reptiles
        brachiosaurus = {intrvl = 30, chance = 0.5, group = 3, biomes = {unpack(shoresbiomes), unpack(swampbiomes)}, nodes = {'group:sand','group:soil','group:water'}},
        carnotaurus = {intrvl = 30, chance = 0.4, group = 3, biomes = otherbiomes, nodes = {'group:soil'}},
        pteranodon = {intrvl = 30, chance = 0.8, group = 6, biomes = {unpack(highlandbiomes), unpack(otherbiomes)}, nodes = {'group:soil','default:permafrost_with_stones','air'}},
        quetzalcoatlus = {intrvl = 30, chance = 0.8, group = 6, biomes = {unpack(highlandbiomes), unpack(otherbiomes)}, nodes = {'group:soil','default:permafrost_with_stones','air'}},
        sarcosuchus = {intrvl = 30, chance = 0.7, group = 3, biomes = {unpack(shoresbiomes), unpack(swampbiomes)}, nodes = {'group:water','group:sand'}},
        spinosaurus = {intrvl = 30, chance = 0.5, group = 3, biomes = {unpack(shoresbiomes), unpack(swampbiomes)}, nodes = {'group:water','group:sand'}},
        stegosaurus = {intrvl = 30, chance = 0.5, group = 6, biomes = otherbiomes, nodes = {'group:soil'}},
        triceratops = {intrvl = 30, chance = 0.6, group = 6, biomes = otherbiomes, nodes = {'group:soil'}},
        tyrannosaurus = {intrvl = 30, chance = 0.4, group = 3, biomes = otherbiomes, nodes = {'group:soil'}},
        velociraptor = {intrvl = 30, chance = 0.6, group = 10, biomes = forestbiomes, nodes = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
        -- mammals
        dire_wolf = {intrvl = 30, chance = 0.8, group = 10, biomes = forestbiomes, nodes = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
        elasmotherium = {intrvl = 30, chance = 0.6, group = 6, biomes = otherbiomes, nodes = {'group:soil'}}, --unicorn!
        mammoth = {intrvl = 30, chance = 0.7, group = 4, biomes = otherbiomes, nodes = {'group:soil','group:snowy','default:ice','default:permafrost_with_stones'}},
        procoptodon = {intrvl = 30, chance = 0.9, group = 6, biomes = savannabiomes, nodes = {'group:soil'}},
        smilodon = {intrvl = 30, chance = 0.7, group = 3, biomes = otherbiomes, nodes = {'group:soil', 'group:snowy', 'default:ice', 'default:permafrost_with_stones'}},
        thylacoleo = {intrvl = 30, chance = 0.9, group = 3, biomes = savannabiomes, nodes = {'group:soil'}},
    }
    -- after defining these mobs, we can add mod dependant stuff to the tables like this:
    -- if minetest.get_modpath('ethereal') then
        -- table.insert(mob_list.tyrannosaurus.nodes, 'ethereal:mushroom_dirt')
    -- end

    for mob, def in pairs(mob_list) do
        mob_core.register_spawn({name = "paleotest:"..mob, nodes = def.nodes, optional = {biomes = def.biomes}}, def.intrvl * paleotest.spawn_rate, def.chance*paleotest.spawn_chance)
    end
end)
