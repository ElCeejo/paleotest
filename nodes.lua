-----------------------
--- PaleoTest Nodes ---
-----------------------
------- Ver 2.0 -------
local creative = minetest.settings:get_bool("creative")

local soils = {}

minetest.register_on_mods_loaded(function()
    for name in pairs(minetest.registered_nodes) do
        if name ~= "air" and name ~= "ignore" then
            if minetest.registered_nodes[name].groups.soil then
                table.insert(soils, name)
            end
        end
    end
end)

------------------
-- Fossil Block --
------------------

minetest.register_node("paleotest:fossil_block", {
    description = "Fossil Block",
    tiles = {"paleotest_fossil_block.png"},
    groups = {cracky = 2},
    drop = {
        max_items = 1,
        items = {
            {items = {'paleotest:fossil'}, rarity = 4},
            {items = {'paleotest:plant_fossil'}, rarity = 4},
            {items = {'bones:bones'}, rarity = 4}, {items = {'default:cobble'}}
        }
    },
    sounds = default.node_sound_stone_defaults()
})

---------------------------
-- Suspicious Permafrost --
---------------------------

minetest.register_node("paleotest:suspicious_permafrost", {
    description = "Suspicious Permafrost",
    tiles = {"paleotest_suspicious_permafrost.png"},
    groups = {crumbly = 2},
    drop = {
        max_items = 1,
        items = {
            {items = {"paleotest:ancient_bones"}, rarity = 4},
            {items = {"bones:bones"}, rarity = 3},
            {items = {"default:permafrost"}}
        }
    },
    sounds = default.node_sound_stone_defaults()
})

-----------
-- Cycad --
-----------

minetest.register_craftitem("paleotest:seeds_cycad", {
    description = "Cycad Seeds",
    inventory_image = "paleotest_seeds_cycad.png",
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing and pointed_thing.type == "node" then
            local under = minetest.get_node(pointed_thing.under)
            local def = minetest.registered_nodes[under.name]
            if placer and itemstack and def and def.on_rightclick then
                return def.on_rightclick(pointed_thing.under, under, placer,
                                         itemstack)
            end
            local above = minetest.get_node(pointed_thing.above)
            if not minetest.registered_nodes[under.name] or
                not minetest.registered_nodes[above.name] then return end
            if not minetest.registered_nodes[above.name].buildable_to or
                minetest.get_item_group(above.name, "seedling") ~= 0 then
                return
            end
            if not minetest.is_protected(pointed_thing.above,
                                         placer:get_player_name()) and
                minetest.registered_nodes[under.name].groups.soil then
                minetest.set_node(pointed_thing.above,
                                  {name = "paleotest:cycad_1", param2 = 4})
                minetest.sound_play("default_place_node",
                                    {pos = pointed_thing.above, gain = 1.0})
                if not creative then
                    itemstack:take_item()
                    return itemstack
                end
            end
        end
    end
})

minetest.register_node("paleotest:cycad_1", {
    drawtype = "plantlike",
    tiles = {"paleotest_cycad_1.png"},
    visual_scale = 1.5,
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 4,
    waving = 1,
    sunlight_propagates = true,
    walkable = false,
    drop = "paleotest:seeds_cycad",
    selection_box = {
        type = "fixed",
        fixed = {{-0.1563, -0.5000, -0.1563, 0.1563, -0.1250, 0.1563}}
    },
    groups = {
        snappy = 3,
        flammable = 4,
        plant = 1,
        attached_node = 1,
        not_in_creative_inventory = 1,
        growing = 1
    },
    sounds = default.node_sound_leaves_defaults(),
    on_construct = function(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,
    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local growth_int = meta:get_int("growth_int") or 0
        local soil_node = minetest.get_node(
                              {x = pos.x, y = pos.y - 1, z = pos.z})
        if soil_node and minetest.registered_nodes[soil_node.name].groups.soil then
            meta:set_int("growth_int", growth_int + 1)
            minetest.get_node_timer(pos):start(1)
        else
            meta:set_int("growth_int", 0)
            minetest.get_node_timer(pos):start(1)
        end
        if growth_int >= 240 then
            meta:set_int("growth_int", 0)
            minetest.swap_node(pos, {name = "paleotest:cycad_2", param2 = 4})
        end
    end
})

minetest.register_node("paleotest:cycad_2", {
    drawtype = "plantlike",
    tiles = {"paleotest_cycad_2.png"},
    visual_scale = 1.5,
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 4,
    waving = 1,
    sunlight_propagates = true,
    walkable = false,
    drop = "paleotest:seeds_cycad",
    selection_box = {
        type = "fixed",
        fixed = {{-0.2188, -0.5000, -0.2188, 0.2188, 0.000, 0.2188}}
    },
    groups = {
        snappy = 3,
        flammable = 4,
        plant = 1,
        attached_node = 1,
        not_in_creative_inventory = 1,
        growing = 1
    },
    sounds = default.node_sound_leaves_defaults(),
    on_construct = function(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,
    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local growth_int = meta:get_int("growth_int") or 0
        local soil_node = minetest.get_node(
                              {x = pos.x, y = pos.y - 1, z = pos.z})
        if soil_node and minetest.registered_nodes[soil_node.name].groups.soil then
            meta:set_int("growth_int", growth_int + 1)
            minetest.get_node_timer(pos):start(1)
        else
            meta:set_int("growth_int", 0)
            minetest.get_node_timer(pos):start(1)
        end
        if growth_int >= 240 then
            meta:set_int("growth_int", 0)
            minetest.swap_node(pos, {name = "paleotest:cycad_3", param2 = 2})
        end
    end
})

minetest.register_node("paleotest:cycad_3", {
    description = "Cycad",
    drawtype = "plantlike",
    tiles = {"paleotest_cycad_3.png"},
    inventory_image = "paleotest_cycad_3.png",
    visual_scale = 2.0,
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 2,
    waving = 1,
    sunlight_propagates = true,
    walkable = false,
    drop = {
        max_items = 1,
        items = {
            {items = {"paleotest:cycad_3"}, rarity = 20},
            {items = {"paleotest:seeds_cycad"}}
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {{-0.3125, -0.5000, -0.3125, 0.3125, 0.5000, 0.3125}}
    },
    groups = {
        snappy = 3,
        flammable = 4,
        plant = 1,
        attached_node = 1,
        growing = 1
    },
    sounds = default.node_sound_leaves_defaults()
})

----------------
-- Horsetails --
----------------

minetest.register_craftitem("paleotest:seeds_horsetail", {
    description = "Horsetail Spores",
    inventory_image = "paleotest_seeds_horsetail.png",
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing and pointed_thing.type == "node" then
            local under = minetest.get_node(pointed_thing.under)
            local def = minetest.registered_nodes[under.name]
            if placer and itemstack and def and def.on_rightclick then
                return def.on_rightclick(pointed_thing.under, under, placer,
                                         itemstack)
            end
            local above = minetest.get_node(pointed_thing.above)
            if not minetest.registered_nodes[under.name] or
                not minetest.registered_nodes[above.name] then return end
            if not minetest.registered_nodes[above.name].buildable_to or
                minetest.get_item_group(above.name, "seedling") ~= 0 then
                return
            end
            if not minetest.is_protected(pointed_thing.above,
                                         placer:get_player_name()) and
                minetest.registered_nodes[under.name].groups.soil then
                minetest.set_node(pointed_thing.above,
                                  {name = "paleotest:horsetail_1", param2 = 2})
                minetest.sound_play("default_place_node",
                                    {pos = pointed_thing.above, gain = 1.0})
                if not creative then
                    itemstack:take_item()
                    return itemstack
                end
            end
        end
    end
})

minetest.register_node("paleotest:horsetail_1", {
    drawtype = "plantlike",
    tiles = {"paleotest_horsetail.png"},
    visual_scale = 0.5,
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 2,
    waving = 1,
    sunlight_propagates = true,
    walkable = false,
    drop = "paleotest:seeds_horsetail",
    selection_box = {
        type = "fixed",
        fixed = {{-0.1563, -0.5000, -0.1563, 0.1563, -0.1250, 0.1563}}
    },
    groups = {
        snappy = 3,
        flammable = 4,
        plant = 1,
        attached_node = 1,
        not_in_creative_inventory = 1,
        growing = 1
    },
    sounds = default.node_sound_leaves_defaults(),
    on_construct = function(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,
    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local growth_int = meta:get_int("growth_int") or 0
        local soil_node = minetest.get_node(
                              {x = pos.x, y = pos.y - 1, z = pos.z})
        if soil_node and minetest.registered_nodes[soil_node.name].groups.soil then
            meta:set_int("growth_int", growth_int + 1)
            minetest.get_node_timer(pos):start(1)
        else
            meta:set_int("growth_int", 0)
            minetest.get_node_timer(pos):start(1)
        end
        if growth_int >= 120 then
            meta:set_int("growth_int", 0)
            minetest.swap_node(pos, {name = "paleotest:horsetail_2", param2 = 2})
        end
    end
})

minetest.register_node("paleotest:horsetail_2", {
    drawtype = "plantlike",
    tiles = {"paleotest_horsetail.png"},
    visual_scale = 1,
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 2,
    waving = 1,
    sunlight_propagates = true,
    walkable = false,
    drop = "paleotest:seeds_horsetail",
    selection_box = {
        type = "fixed",
        fixed = {{-0.2188, -0.5000, -0.2188, 0.2188, 0.000, 0.2188}}
    },
    groups = {
        snappy = 3,
        flammable = 4,
        plant = 1,
        attached_node = 1,
        not_in_creative_inventory = 1,
        growing = 1
    },
    sounds = default.node_sound_leaves_defaults(),
    on_construct = function(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(1)
    end,
    on_timer = function(pos)
        local meta = minetest.get_meta(pos)
        local growth_int = meta:get_int("growth_int") or 0
        local soil_node = minetest.get_node(
                              {x = pos.x, y = pos.y - 1, z = pos.z})
        if soil_node and minetest.registered_nodes[soil_node.name].groups.soil then
            meta:set_int("growth_int", growth_int + 1)
            minetest.get_node_timer(pos):start(1)
        else
            meta:set_int("growth_int", 0)
            minetest.get_node_timer(pos):start(1)
        end
        if growth_int >= 120 then
            meta:set_int("growth_int", 0)
            minetest.swap_node(pos, {name = "paleotest:horsetail_3", param2 = 2})
        end
    end
})

minetest.register_node("paleotest:horsetail_3", {
    description = "Horsetail",
    drawtype = "plantlike",
    tiles = {"paleotest_horsetail.png"},
    inventory_image = "paleotest_horsetail.png",
    visual_scale = 1.5,
    paramtype = "light",
    paramtype2 = "meshoptions",
    place_param2 = 2,
    waving = 1,
    sunlight_propagates = true,
    walkable = false,
    drop = {
        max_items = 1,
        items = {
            {items = {"paleotest:horsetail_3"}, rarity = 20},
            {items = {"paleotest:seeds_horsetail"}}
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {{-0.3125, -0.5000, -0.3125, 0.3125, 0.5000, 0.3125}}
    },
    groups = {
        snappy = 3,
        flammable = 4,
        plant = 1,
        attached_node = 1,
        growing = 1
    },
    sounds = default.node_sound_leaves_defaults(),
    on_construct = function(pos)
        local timer = minetest.get_node_timer(pos)
        timer:start(60)
    end,
    on_timer = function(pos)
        local area = minetest.find_nodes_in_area_under_air(
                         vector.new(pos.x - 1, pos.y - 1, pos.z - 1),
                         vector.new(pos.x + 1, pos.y + 1, pos.z + 1), soils)
        for _, expand_to in ipairs(area) do
            if expand_to then
                expand_to.y = expand_to.y + 1
                local light = minetest.get_node_light(expand_to, 0.5)
                if light <= 13 then
                    minetest.set_node(expand_to, {
                        name = "paleotest:horsetail_1",
                        param2 = 2
                    })
                end
            end
        end
        local timer = minetest.get_node_timer(pos)
        timer:start(60)
    end
})

-----------------
-- Metasequoia --
-----------------

minetest.register_node("paleotest:metasequoia_tree", {
    description = "Metasequoia Tree",
    tiles = {
        "paleotest_metasequoia_tree_top.png",
        "paleotest_metasequoia_tree_top.png", "paleotest_metasequoia_tree.png"
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
    sounds = default.node_sound_wood_defaults(),
    on_place = minetest.rotate_node
})

minetest.register_node("paleotest:metasequoia_leaves", {
    description = "Metasequoia Leaves",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"paleotest_metasequoia_leaves.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
    drop = {
        max_items = 1,
        items = {
            {
                -- player will get sapling with 1/20 chance
                items = {"paleotest:metasequoia_sapling"},
                rarity = 20
            }, {
                -- player will get leaves only if he get no saplings,
                -- this is because max_items is 1
                items = {"paleotest:metasequoia_leaves"}
            }
        }
    },
    sounds = default.node_sound_leaves_defaults(),

    after_place_node = after_place_leaves
})

local function grow_sapling(pos)
    if not default.can_grow(pos) then
        minetest.get_node_timer(pos):start(300)
        return
    end
    local node = minetest.get_node(pos)
    if node.name == "paleotest:metasequoia_sapling" then
        minetest.set_node(pos, {name = "air"})
        minetest.log("action", "A sapling grows into a tree at " ..
                         minetest.pos_to_string(pos))
        pos.x = pos.x - 7
        pos.y = pos.y - math.random(2, 4)
        pos.z = pos.z - 7
        minetest.place_schematic(pos, minetest.get_modpath("paleotest") ..
                                     "/schems/paleotest_metasequoia.mts",
                                 "random", nil, false)
    end
end

minetest.register_node("paleotest:metasequoia_sapling", {
    description = "Metasequoia Sapling",
    drawtype = "plantlike",
    tiles = {"paleotest_metasequoia_sapling.png"},
    inventory_image = "paleotest_metasequoia_sapling.png",
    wield_image = "paleotest_metasequoia_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_timer = grow_sapling,
    selection_box = {
        type = "fixed",
        fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
    },
    groups = {
        snappy = 2,
        dig_immediate = 3,
        flammable = 2,
        attached_node = 1,
        sapling = 1
    },
    sounds = default.node_sound_leaves_defaults(),

    on_construct = function(pos)
        minetest.get_node_timer(pos):start(math.random(1200, 1600))
    end,

    on_place = function(itemstack, placer, pointed_thing)
        itemstack = default.sapling_on_place(itemstack, placer, pointed_thing,
                                             "paleotest:metasequoia_sapling",
                                             {x = -3, y = 1, z = -3},
                                             {x = 3, y = 6, z = 3}, 4)
        return itemstack
    end
})

minetest.register_node("paleotest:metasequoia_wood", {
    description = "Metasequoia Wood Planks",
    paramtype2 = "facedir",
    place_param2 = 0,
    tiles = {"paleotest_metasequoia_wood.png"},
    is_ground_content = false,
    groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3, wood = 1},
    sounds = default.node_sound_wood_defaults()
})

default.register_fence("paleotest:fence_metasequoia", {
    description = "Metasequoia Wood Fence",
    texture = "paleotest_metasequoia_wood.png",
    inventory_image = "default_fence_overlay.png^paleotest_metasequoia_wood.png^" ..
        "default_fence_overlay.png^[makealpha:255,126,126",
    wield_image = "default_fence_overlay.png^paleotest_metasequoia_wood.png^" ..
        "default_fence_overlay.png^[makealpha:255,126,126",
    material = "paleotest:metasequoia_wood",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
    sounds = default.node_sound_wood_defaults()
})

default.register_fence_rail("paleotest:fence_rail_metasequoia", {
    description = "Metasequoia Wood Fence Rail",
    texture = "paleotest_metasequoia_wood.png",
    inventory_image = "default_fence_rail_overlay.png^paleotest_metasequoia_wood.png^" ..
        "default_fence_rail_overlay.png^[makealpha:255,126,126",
    wield_image = "default_fence_rail_overlay.png^paleotest_metasequoia_wood.png^" ..
        "default_fence_rail_overlay.png^[makealpha:255,126,126",
    material = "paleotest:metasequoia_wood",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
    sounds = default.node_sound_wood_defaults()
})

stairs.register_stair_and_slab("metasequoia_wood", "paleotest:metasequoia_wood",
                               {
    choppy = 2,
    oddly_breakable_by_hand = 2,
    flammable = 2
}, {"paleotest_metasequoia_wood.png"}, "Metasequoia Wooden Stair",
                               "Metasequoia Wooden Slab",
                               default.node_sound_wood_defaults(), true)

minetest.register_craft({
    output = "paleotest:metasequoia_wood 4",
    recipe = {{"paleotest:metasequoia_tree"}}
})

---------------------
-- Scratching Post --
---------------------

minetest.register_node("paleotest:scratching_post_top", {
    description = "Scratching Post Top",
    drawtype = "airlike",
    pointable = false,
    groups = {not_in_creative_inventory = 1},
    sounds = default.node_sound_wood_defaults()
})

minetest.register_node("paleotest:scratching_post", {
    description = "Scratching Post",
    drawtype = "mesh",
    mesh = "paleotest_scratching_post.obj",
    tiles = {"paleotest_scratching_post.png"},
    inventory_image = "paleotest_scratching_post_inv.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.3125, -0.5000, -0.3125, 0.3125, 1.125, 0.3125}
    },
    groups = {snappy = 3, level = 1},
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z},
                          {name = "paleotest:scratching_post_top"})
    end,
    on_destruct = function(pos)
        minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z}, {name = "air"})
    end
})

--------------------
-- Dinosaur Fence --
--------------------

if minetest.get_modpath("default") and default.register_fence_rail then
    default.register_fence_rail("paleotest:electric_fence_wires", {
        description = "Electrified Fence Wires",
        texture = "paleotest_dinosaur_fence.png",
        inventory_image = "default_fence_rail_overlay.png^paleotest_dinosaur_fence.png^" ..
            "default_fence_rail_overlay.png^[makealpha:255,126,126",
        wield_image = "default_fence_rail_overlay.png^paleotest_dinosaur_fence.png^" ..
            "default_fence_rail_overlay.png^[makealpha:255,126,126",
        material = "default:steelblock",
        connects_to = {"paleotest:steel", "paleotest:dinosaur_fence"},
        groups = {cracky = 1, level = 2, igniter = 1},
        damage_per_second = 9,
        sounds = default.node_sound_metal_defaults()
    })
end

if minetest.get_modpath("walls") then
    walls.register("paleotest:steel", "Steel Wall", {
        "paleotest_steel_wall_top.png", "paleotest_steel_wall_top.png",
        "paleotest_steel_wall.png"
    }, "default:steelblock", default.node_sound_metal_defaults())
end
