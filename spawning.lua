local mob_list = {
    -- create item for every mob with fine tuned settings here
    brachiosaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass','default:river_water_source'}},
    carnotaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    dire_wolf = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass','default:dirt_with_rainforest_litter'}},
    dunkleosteus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:water_source'}},
    elasmotherium = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}}, --unicorn!
    mammoth = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass','default:snowblock','default:ice','default:dirt_with_snow','default:permafrost_with_stones'}},
    mosasaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:water_source'}},
    plesiosaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:water_source'}},
    procoptodon = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    pteranodon = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    quetzalcoatlus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    sarcosuchus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:river_water_source','default:sand'}},
    smilodon = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    spinosaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    stegosaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    thylacoleo = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    triceratops = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    tyrannosaurus = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass'}},
    velociraptor = {intrvl = 50, chance = 0.1, reduction = 0, near = {'default:dirt_with_grass','default:dirt_with_dry_grass','default:dry_dirt_with_dry_grass','default:dirt_with_coniferous_litter','default:dirt_with_rainforest_litter'}},
}
-- after defining these mobs, we can add mod dependant materials to the near array like this:
if minetest.get_modpath('ethereal') then
    table.insert(mob_list.tyrannosaurus.near, 'ethereal:mushroom_dirt')
end

local radius = 32 -- I expect the radius to be the same for every mob, if not we can add it as an item in the mob definitions array above, which would be accessed below as def.radius
for mob, def in ipairs(mob_list) do
    minetest.register_globalstep(function(dtime)
        local spawnpos = mobkit.get_spawn_pos_abr(dtime, def.intrvl, radius, def.chance, def.reduction)
        if spawnpos then
            -- either search for a single matching node in radius or find all nodes that match in an area
            local pos1 = {x = spawnpos.x + radius, y = spawnpos.y + radius, z = spawnpos.z + radius}
            local pos2 = {x = spawnpos.x - radius, y = spawnpos.y - radius, z = spawnpos.z - radius}
            if minetest.find_nodes_in_area(pos1, pos2, def.near) then
            -- if minetest.find_node_near(spawnpos, radius, def.near, true)
                minetest.add_entity(spawnpos, "paleotest:"..mob)
            end
        end
    end)
end
