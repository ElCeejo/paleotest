----------------------------
-- Registration Functions --
----------------------------
---------- Ver 2.0 ---------

local creative = minetest.settings:get_bool("creative_mode")

local heat_nodes = {}

minetest.register_on_mods_loaded(function()
    for name in pairs(minetest.registered_nodes) do
        if name ~= "air" and name ~= "ignore" then
            if minetest.registered_nodes[name].light_source and
                minetest.registered_nodes[name].light_source >= 12 then
                table.insert(heat_nodes, name)
            end
        end
    end
end)

local common_names = {
    "cow", "calf", "pig", "hog", "lamb", "sheep", "goat", "deer", "dire_wolf",
    "elasmotherium", "procoptodon", "mammoth", "smilodon", "thylacoleo"
}

local function round(x) return x + 0.5 - (x + 0.5) % 1 end

local function blk(text)
    if type(text) ~= "string" then return end
    local output = minetest.colorize("#000000", text)
    return output
end

local SF = mob_core.get_name_proper

minetest.register_on_mods_loaded(function()
    -- We do this by overwriting on_step of all entities
    for name, def in pairs(minetest.registered_entities) do
        if minetest.registered_entities[name].get_staticdata == mobkit.statfunc then
            -- On Activate
            local old_act = def.on_activate
            if not old_act then old_act = function() end end
            local on_activate = function(self, staticdata, dtime_s)
                old_act(self, staticdata, dtime_s)
                self.paleo_pregnant_data =
                    mobkit.recall(self, "paleo_pregnant_data") or nil
            end
            def.on_activate = on_activate
            -- On Step
            local old_step = def.on_step
            if not old_step then old_step = function() end end
            local on_step = function(self, dtime, moveresult)
                old_step(self, dtime, moveresult)
                if self.paleo_pregnant_data then
                    if self.paleo_pregnant_data.timer > 0 then
                        self.paleo_pregnant_data.timer =
                            self.paleo_pregnant_data.timer - dtime
                    else
                        local pos = self.object:get_pos()
                        if self.paleo_pregnant_data.imprint then
                            paleotest.spawn_imprinted_child(pos,
                                                            self.paleo_pregnant_data
                                                                .mob)
                            self.paleo_pregnant_data = nil
                        else
                            mob_core.spawn_child(pos,
                                                 self.paleo_pregnant_data.mob)
                            self.paleo_pregnant_data = nil
                        end
                    end
                    mobkit.remember(self, "paleo_pregnant_data",
                                    self.paleo_pregnant_data)
                end
            end
            def.on_step = on_step
            -- On Rightclick
            local old_click = def.on_rightclick
            if not old_click then old_click = function() end end
            local on_rightclick = function(self, clicker)
                local item = clicker:get_wielded_item():get_name()
                if not self.name:match("^paleotest:") then
                    if item == "paleotest:field_guide" then
                        paleotest.fg_pregnant_progress(self, clicker)
                        return
                    end
                    if minetest.registered_items[item].groups.paleo_syringe == 1 then
                        return
                    end
                end
                old_click(self, clicker)
            end
            def.on_rightclick = on_rightclick
            minetest.register_entity(":" .. name, def)
        end
    end
end)

local function first_to_upper(str) return (str:gsub("^%l", string.upper)) end

----------------------------------
-- Register Field Guide Entries --
----------------------------------

function paleotest.register_fg_entry(self, def)
    local name = mob_core.get_name_proper(self.name)
    local health = self.hp / self.max_hp * 100
    local hunger = self.hunger / self.max_hunger * 100
    local owner = tostring(self.owner)
    local gender = first_to_upper(tostring(self.gender))
    local order = first_to_upper(tostring(self.order))
    local attacks = first_to_upper(tostring(self.attacks))
    local growth = ""
    if self.growth_stage == 1 then
        growth = "Baby"
    elseif self.growth_stage == 2 then
        growth = "Juvenile"
    elseif self.growth_stage == 3 then
        growth = "Sub-Adult"
    elseif self.growth_stage == 4 then
        growth = "Adult"
    end
    if owner == "nil" then owner = "None" end
    if order == "Nil" then order = "None" end
    if def.image then
        def.image = def.image
    elseif self.gender == "female" then
        def.image = def.female_image
    else
        def.image = def.male_image
    end
    local field_guide_formspec = {
        "formspec_version[3]", "size[16,10]",
        "background[-0.7,-0.5;17.5,11.5;paleotest_field_guide_formspec.png]",
        -- Basic Info
        "label[3,1;", blk(name), "]", "image[0,0;8,8;" .. def.image .. "]",
        "label[2.5,7;", blk("Temperament: " .. def.temper), "]",
        "label[2.5,7.3;", blk("Diet: " .. def.diet), "]", "label[2.5,7.6;",
        blk("Owner: " .. owner), "]", "label[2.5,7.9;",
        blk("Gender: " .. gender), "]", "label[2.5,8.2;",
        blk("Order: " .. order), "]", "label[2.5,8.5;",
        blk("Attacks: " .. attacks), "]", "label[2.5,8.8;",
        blk("Growth Stage: " .. growth), "]", -- Health
        "label[12,1.5;", blk("Health"), "]",
        "image[11,2;3,3;paleotest_field_guide_hp_bar.png^[lowpart:" .. health ..
            ":paleotest_field_guide_hp_bar_full.png]", -- Hunger
        "label[14,5.5;", blk("Hunger"), "]",
        "image[13,6;3,3;paleotest_field_guide_bar.png^[lowpart:" .. hunger ..
            ":paleotest_field_guide_bar_full.png]", -- Mood
        "label[10,5.5;", blk("Mood"), "]",
        "image[9,6;3,3;paleotest_field_guide_mood_bar_down.png^[lowpart:" ..
            (self.mood) .. ":paleotest_field_guide_mood_bar_up.png]"
    }
    return table.concat(field_guide_formspec, "")
end

--------------
-- Egg Page --
--------------

function paleotest.fg_egg_progress(self, clicker)
    local form = function(self)
        local name = first_to_upper(self.mob_id)
        local formspec = {
            "formspec_version[3]", "size[16,10]",
            "background[-0.7,-0.5;17.5,11.5;paleotest_field_guide_formspec.png]",
            -- Basic Info
            "label[3,1;", blk(name .. " Egg"), "]",
            "image[0,1;8,8;paleotest_egg_" .. self.mob_id .. ".png]", -- Health
            "label[11.75,1.25;", blk("Progress:" .. round(self.progress)), "]",
            "image[11,2;3,6;paleotest_field_guide_bar_egg.png^[lowpart:" ..
                (self.progress) .. ":paleotest_field_guide_bar_egg_full.png]"
        }
        return table.concat(formspec, "")
    end
    minetest.show_formspec(clicker:get_player_name(),
                           "paleotest:fg_egg_progress", form(self))
end

-----------------------
-- Pregnant Mob Page --
-----------------------

function paleotest.fg_pregnant_progress(self, clicker)
    if not self.paleo_pregnant_data then return end
    local form = function(self)
        local name = SF(self.paleo_pregnant_data.mob)
        local timer = self.paleo_pregnant_data.timer
        local formspec = {
            "formspec_version[3]", "size[16,10]",
            "background[-0.7,-0.5;17.5,11.5;paleotest_field_guide_formspec.png]",
            -- Basic Info
            "label[2,1;", blk("Pregnant with: " .. name), "]",
            "image[0,1;8,8;paleotest_syringe.png]", -- Health
            "label[11.75,1.25;", blk("Progress:" .. round(timer)), "]",
            "image[11,2;3,6;paleotest_field_guide_bar_egg.png^[lowpart:" ..
                timer .. ":paleotest_field_guide_bar_egg_full.png]"
        }
        return table.concat(formspec, "")
    end
    minetest.show_formspec(clicker:get_player_name(),
                           "paleotest:fg_pregnant_progress", form(self))
end

-------------------------
-- Register Embryo Sac --
-------------------------

function paleotest.register_embryo_sac(mob, imprint)
    local desc = mob_core.get_name_proper(mob)
    local mob_name = mob:split(":")[2]
    minetest.register_craftitem("paleotest:sac_" .. mob_name, {
        description = desc .. " Embryonic Sac",
        inventory_image = "paleotest_embryo_sac.png",
        wield_image = "paleotest_embryo_sac.png",
        stack_max = 1,
        on_place = function(itemstack, _, pointed_thing)
            local pos = minetest.get_pointed_thing_position(pointed_thing, true)
            minetest.add_particlespawner(
                {
                    amount = 6,
                    time = 0.25,
                    minpos = {
                        x = pos.x - 7 / 16,
                        y = pos.y - 5 / 16,
                        z = pos.z - 7 / 16
                    },
                    maxpos = {
                        x = pos.x + 7 / 16,
                        y = pos.y - 5 / 16,
                        z = pos.z + 7 / 16
                    },
                    minvel = vector.new(-1, 2, -1),
                    maxvel = vector.new(1, 5, 1),
                    minacc = vector.new(0, -9.81, 0),
                    maxacc = vector.new(0, -9.81, 0),
                    collisiondetection = true,
                    texture = "paleotest_blood_particle.png"
                })
            if imprint then
                paleotest.spawn_imprinted_child(pos, mob)
            else
                mob_core.spawn_child(pos, mob)
            end
            if not creative then
                itemstack:take_item()
                return itemstack
            end
        end
    })
end

-----------------------
-- Register Syringes --
-----------------------

function paleotest.register_syringe(mob, imprint)
    local desc = mob_core.get_name_proper(mob)
    local mob_name = mob:split(":")[2]
    minetest.register_craftitem("paleotest:syringe_" .. mob_name, {
        description = desc .. " Syringe",
        inventory_image = "paleotest_syringe.png",
        groups = {paleo_syringe = 1},
        on_secondary_use = function(itemstack, player, pointed_thing)
            if pointed_thing.type == "object" then
                local ent = pointed_thing.ref:get_luaentity()
                for i = 1, #common_names do
                    if (ent.logic or ent.brainfunc) and
                        ent.name:match(common_names[i]) or ent.name == mob then
                        if ent.gender and ent.gender == "male" then
                            return
                        end
                        if not ent.paleo_pregnant_data then
                            paleotest.particle_spawner(
                                pointed_thing.ref:get_pos(), "heart.png",
                                "float")
                            ent.paleo_pregnant_data =
                                {mob = mob, timer = 10, imprint = imprint}
                            ent.paleo_pregnant_data =
                                mobkit.remember(ent, "paleo_pregnant_data",
                                                ent.paleo_pregnant_data)
                            if not creative then
                                itemstack:take_item()
                                return itemstack
                            end
                        else
                            minetest.chat_send_player(player:get_player_name(),
                                                      "This mob is already pregnant")
                            return
                        end
                    end
                end
            end
        end
    })
end

-------------------
-- Register Eggs --
-------------------

function paleotest.spawn_imprinted_child(pos, mob)
    local child = minetest.add_entity(pos, mob)
    local luaent = child:get_luaentity()
    luaent.child = mobkit.remember(luaent, "child", true)
    luaent.growth_timer = mobkit.remember(luaent, "growth_timer", 1)
    luaent.growth_stage = mobkit.remember(luaent, "growth_stage", 1)
    mob_core.set_scale(luaent, luaent.scale_stage1 or 0.25)
    mob_core.set_textures(luaent)
    mob_core.hq_roam(luaent, 0)
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
        if obj and obj:is_player() then
            minetest.after(1.5, function()
                luaent.tamed = mobkit.remember(luaent, "tamed", true)
                luaent.owner = mobkit.remember(luaent, "owner",
                                               obj:get_player_name())
                minetest.chat_send_player(obj:get_player_name(),
                                          mob_core.get_name_proper(mob) ..
                                              " has been imprinted.")
            end)
        end
    end
end

function paleotest.register_egg(mob, scale, imprint)

    local mob_name = mob:split(":")[2]

    local function pickup_egg(self, player)
        local inv = player:get_inventory()
        if inv:room_for_item("main", {name = "paleotest:egg_" .. mob_name}) then
            player:get_inventory()
                :add_item("main", "paleotest:egg_" .. mob_name)
        else
            local pos = self.object:get_pos()
            pos.y = pos.y + 0.5
            minetest.add_item(pos, {name = "paleotest:egg_" .. mob_name})
        end
        self.object:remove()
    end

    minetest.register_craftitem("paleotest:egg_" .. mob_name, {
        description = SF(mob) .. " Egg",
        groups = {egg = 1},
        inventory_image = "paleotest_egg_" .. mob_name .. ".png",
        on_place = function(itemstack, _, pointed_thing)
            local pos = minetest.get_pointed_thing_position(pointed_thing, true)
            pos.y = pos.y + 0.5
            minetest.add_entity(pos, "paleotest:egg_" .. mob_name .. "_ent")
            if not creative then
                itemstack:take_item()
                return itemstack
            end
        end
    })

    minetest.register_entity("paleotest:egg_" .. mob_name .. "_ent", {
        -- Stats
        max_hp = 10,
        armor_groups = {immortal = 1},
        -- Movement & Physics
        max_speed = 0,
        stepheight = 0,
        jump_height = 0,
        buoyancy = 0.5,
        springiness = 0,
        -- Visual
        collisionbox = {-0.15, -0.5, -0.15, 0.15, 0.0, 0.15},
        visual_size = {x = 10, y = 10},
        visual = "mesh",
        mesh = "paleotest_egg.b3d",
        textures = {"paleotest_egg_" .. mob_name .. "_mesh.png"},
        -- Basic
        mob_id = mob_name,
        progress = 0,
        physical = true,
        collide_with_objects = true,
        static_save = true,
        timeout = 0,
        logic = function() end,
        get_staticdata = mobkit.statfunc,
        on_activate = function(self, staticdata, dtime_s)
            mobkit.actfunc(self, staticdata, dtime_s)
            mob_core.set_scale(self, scale)
            self.progress = mobkit.recall(self, "progress")
        end,
        on_step = function(self, dtime)
            mobkit.stepfunc(self, dtime)
            local pos = self.object:get_pos()
            mob_core.collision_detection(self)
            mobkit.remember(self, "progress", self.progress)
            if minetest.find_node_near(pos, 1, heat_nodes) then
                self.progress = self.progress + dtime
                if self.progress >= 90 and not self.hatching then
                    self.hatching = true
                    self.object:set_animation({x = 1, y = 40}, 30, 0)
                end
                if self.progress >= 100 then
                    if imprint then
                        paleotest.spawn_imprinted_child(pos, mob)
                    else
                        mob_core.spawn_child(pos, mob)
                    end
                    paleotest.particle_spawner(pos,
                                               "paleotest_egg_fragment.png",
                                               "splash")
                    self.object:remove()
                end
            else
                self.progress = 0
                self.hatching = false
                self.object:set_animation({x = 0, y = 0}, 0, 0)
            end
        end,
        on_rightclick = function(self, clicker)
            if clicker:get_wielded_item():get_name() == "paleotest:field_guide" then
                paleotest.fg_egg_progress(self, clicker)
            else
                pickup_egg(self, clicker)
            end
        end,
        on_punch = function(self, puncher) pickup_egg(self, puncher) end
    })
end
