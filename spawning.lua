local mob_list = {
    -- create item for every mob with fine tuned settings here
    tyrannosaurus = {intrvl = 1, chance = 1, reduction = 0, near = {'default:dirt_with_grass'}},
}
-- after defining these mobs, we can add mod dependant materials to the near array like this:
if minetest.get_modpath('ethereal')
    table.insert(mob_list.tyrannosaurus.near, 'ethereal:mushroom_dirt')
end

local radius = 32 -- I expect the radius to be the same for every mob, if not we can add it as an item in the mob definitions array above, which would be accessed below as def.radius
for mob, def in ipairs(mob_list) do
    minetest.register_globalstep(function(dtime)
        local spawnpos = mobkit.get_spawn_pos_abr(dtime, def.intrvl, radius, def.chance, def.reduction)
        if spawnpos then
            -- either search for a single matching node in radius or find all nodes that match in an area
            -- if minetest.find_nodes_in_area(pos1, pos2, def.near)
            if minetest.find_node_near(spawnpos, radius, def.near, true)
                minetest.add_entity(spawnpos, "paleotest:"..mob)
                local self = minetest.registered_entities["paleotest:"..mob]
                mobkit.clear_queue_high(self)
                mobkit.clear_queue_low(self)
                self.status = mobkit.remember(self, "status", "")
                self.order = mobkit.remember(self, "order", "wander")
            end
        end
    end)
end
