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
    for biome, entry in pairs(minetest.registered_biomes) do
        -- minetest.log('debug', '[paleotest] Discovered biome named '..biome)
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
        elseif string.find(biome, 'desert') then
            table.insert(desertbiomes, biome)
        else
            table.insert(otherbiomes, biome)
        end
    end
    -- minetest.log("debug", "[MOD] PaleoTest found these "..table.getn(allbiomes).." biomes "..dump(allbiomes))
    local mob_list = {
        -- create item for every mob with fine-tuned settings here
        brachiosaurus = {intrvl = 5, chance = 0.5, group = 3, biomes = {unpack(shoresbiomes), unpack(swampbiomes), unpack(otherbiomes)}, nodes = {'group:soil','group:water'}},
        carnotaurus = {intrvl = 5, chance = 0.5, group = 3, biomes = otherbiomes, nodes = {'group:soil'}},
        dire_wolf = {intrvl = 5, chance = 0.5, group = 10, biomes = forestbiomes, nodes = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
        dunkleosteus = {intrvl = 5, chance = 0.5, group = 4, biomes = oceanbiomes, nodes = {'group:water'}},
        elasmotherium = {intrvl = 5, chance = 0.5, group = 6, biomes = otherbiomes, nodes = {'group:soil'}}, --unicorn!
        mammoth = {intrvl = 5, chance = 0.5, group = 4, biomes = otherbiomes, nodes = {'group:soil','group:snowy','default:ice','default:permafrost_with_stones'}},
        mosasaurus = {intrvl = 5, chance = 0.5, group = 2, biomes = oceanbiomes, nodes = {'group:water'}},
        plesiosaurus = {intrvl = 5, chance = 0.5, group = 2, biomes = oceanbiomes, nodes = {'group:water'}},
        procoptodon = {intrvl = 5, chance = 0.5, group = 6, biomes = otherbiomes, nodes = {'group:soil'}},
        pteranodon = {intrvl = 5, chance = 0.5, group = 6, biomes = {unpack(highlandbiomes), unpack(otherbiomes)}, nodes = {'group:soil', 'default:permafrost_with_stones'}},
        quetzalcoatlus = {intrvl = 5, chance = 0.5, group = 6, biomes = {unpack(highlandbiomes), unpack(otherbiomes)}, nodes = {'group:soil', 'default:permafrost_with_stones'}},
        sarcosuchus = {intrvl = 5, chance = 0.5, group = 3, biomes = {unpack(shoresbiomes), unpack(swampbiomes)}, nodes = {'group:water','group:sand'}},
        smilodon = {intrvl = 5, chance = 0.5, group = 2, biomes = otherbiomes, nodes = {'group:soil', 'group:snowy', 'default:ice', 'default:permafrost_with_stones'}},
        spinosaurus = {intrvl = 5, chance = 0.5, group = 3, biomes = {unpack(shoresbiomes), unpack(swampbiomes)}, nodes = {'group:sand', 'group:water'}},
        stegosaurus = {intrvl = 5, chance = 0.5, group = 6, biomes = otherbiomes, nodes = {'group:soil'}},
        thylacoleo = {intrvl = 5, chance = 0.5, group = 3, biomes = otherbiomes, nodes = {'group:soil'}},
        triceratops = {intrvl = 5, chance = 0.5, group = 6, biomes = otherbiomes, nodes = {'group:soil'}},
        tyrannosaurus = {intrvl = 5, chance = 0.5, group = 3, biomes = otherbiomes, nodes = {'group:soil'}},
        velociraptor = {intrvl = 5, chance = 0.5, group = 10, biomes = forestbiomes, nodes = {'default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
    }
    -- after defining these mobs, we can add mod dependant stuff to the near array like this:
    -- if minetest.get_modpath('ethereal') then
        -- table.insert(mob_list.tyrannosaurus.nodes, 'ethereal:mushroom_dirt')
    -- end

    for mob, def in pairs(mob_list) do
        local spawn_timer = 0
        minetest.register_globalstep(function(dtime)
            spawn_timer = spawn_timer + dtime
            if spawn_timer > (def.intrvl * paleotest.spawn_rate) then
                if math.random(1, def.chance * paleotest.spawn_chance) == 1 then
                    mob_core.spawn("paleotest:"..mob, def.nodes or {"group:soil", "group:stone"}, 0, minetest.LIGHT_MAX, -31000, 31000, 24, 256, def.group or 1, {biomes = def.biomes})
                end
                spawn_timer = 0
            end
        end)
        -- mob_core.register_spawn({name = "paleotest:"..mob, nodes = def.nodes, optional = {biomes = def.biomes}}, def.intrvl, def.chance)
    end
end)
