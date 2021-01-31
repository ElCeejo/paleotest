---------------------
-- Fossil Analyzer --
---------------------
------ Ver 2.0 ------
--------------
-- Formspec --
--------------
local feeder_fs = "formspec_version[3]" .. "size[12.75,9.5]" ..
                      "background[-1.25,-0.25;15,10;paleotest_machine_formspec.png]" ..
                      "image[5.15,1.25;2.25,2.25;paleotest_field_guide_bar.png]" ..
                      "list[current_player;main;1.5,4;8,4;]" ..
                      "list[context;input;3.5,1.75;1,1;]" ..
                      "listring[current_player;main]" ..
                      "listring[context;input]" ..
                      "listring[current_player;main]"

local function get_active_feeder_fs(food_level)
    local form = {
        "formspec_version[3]", "size[12.75,9.5]",
        "background[-1.25,-0.25;15,10;paleotest_machine_formspec.png]",
        "image[5.15,1.25;2.25,2.25;paleotest_field_guide_bar.png^[lowpart:" ..
            (food_level) .. ":paleotest_field_guide_bar_full.png]",
        "list[current_player;main;1.5,4;8,4;]",
        "list[context;input;3.5,1.75;1,1;]", "listring[current_player;main]",
        "listring[context;input]", "listring[current_player;main]"
    }
    return table.concat(form, "")
end

function paleotest.feeder_update_formspec(meta)
    local formspec
    local food_level = meta:get_int("food_level") or 0
    if food_level > 0 then
        local food_percentage = math.floor(food_level / 1000 * 100)
        formspec = get_active_feeder_fs(food_percentage)
    else
        formspec = feeder_fs
    end
    meta:set_string("formspec", formspec)
end

----------
-- Node --
----------

function paleotest.register_feeder(name, def)
    minetest.register_node(name, {
        description = def.description,
        tiles = def.tiles,
        paramtype2 = "facedir",
        groups = {cracky = 2, tubedevice = 1, tubedevice_receiver = 1},
        legacy_facedir_simple = true,
        is_ground_content = false,
        sounds = default.node_sound_stone_defaults(),
        drawtype = "node",

        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_string("formspec", feeder_fs)
            meta:set_int("food_level", 0)
            local inv = meta:get_inventory()
            inv:set_size("items", 32)
            inv:set_size("input", 1)
        end,

        allow_metadata_inventory_put = function(pos, listname, _, stack, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            if listname == "input" then
                return paleotest.find_string(def.input, stack:get_name()) and
                           stack:get_count() or 0
            end
            return 0
        end,

        allow_metadata_inventory_take = function(pos, _, _, stack, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            return stack:get_count()
        end,

        on_metadata_inventory_put = function(pos, _, _, stack) -- Recalculate on_put
            local meta = minetest.get_meta(pos)
            local food_level = meta:get_int("food_level") or 0
            local inv = meta:get_inventory()
            if not paleotest.find_string(def.input, stack:get_name()) then
                return false
            end
            if food_level + stack:get_count() < 1000 then
                meta:set_int("food_level", food_level + stack:get_count())
                if inv:room_for_item("items", stack) then
                    inv:add_item("items", stack)
                end
                inv:remove_item("input", stack)
            end
            paleotest.feeder_update_formspec(meta)
        end,

        on_feed = function(pos, take)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local size = inv:get_size("items")
            local stack = inv:get_stack("items", 1)
            while stack:get_count() < 1 do
                for i = 1, size do
                    local stack_i = inv:get_stack("items", i)
                    inv:set_stack("items", i - 1, stack_i)
                end
                stack = inv:get_stack("items", 1)
            end
            local def = minetest.registered_items[stack:get_name()]
            local texture = def.inventory_image
            if (not texture
            or texture == "")
            and def.tiles then
                texture = def.tiles[1]
            end
            paleotest.particle_spawner(pos, texture, "splash")
            if stack:get_count() - take >= 0 then
                stack:take_item(take)
                inv:set_stack("items", 1, stack)
                return stack
            else
                local leftover = math.abs(stack:get_count() - take)
                stack:take_item(leftover)
                inv:set_stack("items", 1, stack)
                return stack
            end
        end,

        on_blast = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local size = inv:get_size("items")
            for i = 1, size do
                local stack = inv:get_stack("items", i)
                local item = stack:get_name()
                local count = stack:get_count()
                minetest.add_item(pos, item .. " " .. count)
            end
            minetest.add_item(pos, name)
            minetest.remove_node(pos)
        end,

        on_dig = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local size = inv:get_size("items")
            for i = 1, size do
                local stack = inv:get_stack("items", i)
                local item = stack:get_name()
                local count = stack:get_count()
                minetest.add_item(pos, item .. " " .. count)
            end
            minetest.remove_node(pos)
        end
    })
end

paleotest.register_feeder("paleotest:feeder_carnivore", {
    description = "Carnivore Feeder",
    tiles = {
        "paleotest_feeder_carnivore_top.png",
        "paleotest_fossil_analyzer_bottom.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png"
    },
    input = paleotest.global_meat
})

paleotest.register_feeder("paleotest:feeder_piscivore", {
    description = "Piscivore Feeder",
    tiles = {
        "paleotest_feeder_piscivore_top.png",
        "paleotest_fossil_analyzer_bottom.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png"
    },
    input = paleotest.global_fish
})

paleotest.register_feeder("paleotest:feeder_herbivore", {
    description = "Herbivore Feeder",
    tiles = {
        "paleotest_feeder_herbivore_top.png",
        "paleotest_fossil_analyzer_bottom.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png",
        "paleotest_fossil_analyzer_side.png"
    },
    input = paleotest.global_plants
})
