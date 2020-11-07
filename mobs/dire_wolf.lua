---------------
-- Dire Wolf --
---------------

local function set_mob_tables(self)
    for _, entity in pairs(minetest.luaentities) do
        local name = entity.name
        if name ~= self.name and
            paleotest.find_string(paleotest.mobkit_mobs, name) then
            local height = entity.height
            if not paleotest.find_string(self.targets, name) and height and
                height < 2.5 then
                if entity.object:get_armor_groups() and
                    entity.object:get_armor_groups().fleshy then
                    table.insert(self.targets, name)
                elseif entity.name:match("^petz:") then
                    table.insert(self.targets, name)
                end
                if entity.targets and
                    paleotest.find_string(entity.targets, self.name) and
                    not not paleotest.find_string(self.predators, name) then
                    if entity.object:get_armor_groups() and
                        entity.object:get_armor_groups().fleshy then
                        table.insert(self.predators, name)
                    end
                end
            end
        end
    end
end

local function get_pack_size(self)
    local pos = self.object:get_pos()
    local objs = minetest.get_objects_inside_radius(pos, self.view_range)
    if #objs < 1 then return end
    for i = #objs, 1, -1 do
        if objs[i]:is_player() then
            table.remove(objs, i)
        else
            local ent = objs[i]:get_luaentity()
            if ent and ent.name ~= self.name then
                table.remove(objs, i)
            end
            self.pack_size = mobkit.remember(self, "pack_size", #objs)
        end
    end
end

local function get_predators_in_area(self)
    local pos = self.object:get_pos()
    local objs = minetest.get_objects_inside_radius(pos, self.view_range)
    if #objs < 1 then return end
    for i = #objs, 1, -1 do
        if objs[i]:is_player() then
            table.remove(objs, i)
        else
            local ent = objs[i]:get_luaentity()
            if ent and not paleotest.find_string(self.predators, ent.name) then
                table.remove(objs, i)
            end
            self.total_predators = mobkit.remember(self, "total_predators",
                                                   #objs)
        end
    end
end

local function dire_wolf_logic(self)

    if self.hp <= 0 then
        mob_core.on_die(self)
        return
    end

    set_mob_tables(self)

    local prty = mobkit.get_queue_priority(self)
    local player = mobkit.get_nearby_player(self)

    if mobkit.timer(self, 1) then

        get_pack_size(self)
        get_predators_in_area(self)

        if self.order == "stand" and self.mood > 50 then
            mobkit.animate(self, "stand")
            return
        end

        if self.pack_size > self.total_predators and self.status == "fleeing" then
            mobkit.clear_queue_high(self)
        end

        if prty < 18 and self.isinliquid then
            mob_core.hq_liquid_recovery(self, 18, "walk")
            return
        end

        if prty < 16 and self.owner_target then
            mob_core.logic_attack_mob(self, 16, self.owner_target)
        end

        if self.status ~= "sleeping" then

            if prty < 14 then
                if self.hunger < self.max_hunger and self.feeder_timer == 1 then
                    if math.random(1, 2) == 1 then
                        paleotest.hq_go_to_feeder(self, 14,
                                                  "paleotest:feeder_carnivore")
                    else
                        paleotest.hq_eat_items(self, 14)
                    end
                end
            end

            if prty < 12 then
                if self.status == "sleeping" then return end
                if not self.child then
                    if self.attacks == "mobs" or self.attacks == "all" then
                        table.insert(self.targets, self.name)
                        if self.pack_size > self.total_predators then
                            mob_core.logic_attack_mobs(self, 12)
                        elseif self.pack_size <= self.total_predators then
                            mob_core.logic_runaway_mob(self, 12, self.predators)
                        end
                    end
                    if self.mood < 50 or not self.tamed then
                        if self.pack_size > self.total_predators then
                            mob_core.logic_attack_mobs(self, 12)
                        elseif self.pack_size <= self.total_predators then
                            mob_core.logic_runaway_mob(self, 12, self.predators)
                        end
                    end
                end
            end

            if prty < 10 then
                if player and not self.child then
                    if self.mood > 50 and player:get_player_name() ~= self.owner then
                        mob_core.logic_attack_player(self, 10, player)
                    elseif self.mood < 50 then
                        mob_core.logic_attack_player(self, 10, player)
                    end
                end
            end
    
            if prty < 8 then
                if self.mood > 50 then
                    mob_core.hq_follow_holding(self, 8, player)
                end
            end
    
            if prty < 6 then
                if math.random(1, self.mood) == 1 then
                    if math.random(1, 2) == 1 then
                        paleotest.logic_play_with_post(self, 6)
                    else
                        paleotest.logic_play_with_ball(self, 6)
                    end
                end
            end
        end

        if prty < 2 then
            if self.sleep_timer <= 0 and self.status ~= "following" then
                paleotest.hq_sleep(self, 2)
            end
        end

        if mobkit.is_queue_empty_high(self) then
            mob_core.hq_roam(self, 0)
        end
    end
end

minetest.register_entity("paleotest:dire_wolf", {
    -- Stats
    max_hp = 32,
    armor_groups = {fleshy = 100},
    view_range = 16,
    reach = 3,
    damage = 4,
    knockback = 2,
    lung_capacity = 40,
    -- Movement & Physics
    max_speed = 6.5,
    stepheight = 1.26,
    jump_height = 1.26,
    max_fall = 4,
    buoyancy = 0.25,
    springiness = 0,
    -- Visual
    collisionbox = {-0.3, -0.5, -0.3, 0.3, 0.4, 0.3},
    visual_size = {x = 8, y = 8},
    scale_stage1 = 0.45,
    scale_stage2 = 0.65,
    scale_stage3 = 0.85,
    visual = "mesh",
    mesh = "paleotest_dire_wolf.b3d",
    textures = {
        "paleotest_dire_wolf_white.png", "paleotest_dire_wolf_black.png"
    },
    child_textures = {
        "paleotest_dire_wolf_white.png^paleotest_dire_wolf_child_eyes.png",
        "paleotest_dire_wolf_black.png^paleotest_dire_wolf_child_eyes.png"
    },
    animation = {
        walk = {range = {x = 1, y = 40}, speed = 35, loop = true},
        run = {range = {x = 1, y = 40}, speed = 45, loop = true},
        stand = {range = {x = 50, y = 89}, speed = 15, loop = true},
        punch = {range = {x = 100, y = 130}, speed = 20, loop = false},
        sleep = {range = {x = 140, y = 160}, speed = 5, loop = true}
    },
    -- Sound
    sounds = {
        alter_child_pitch = true,
        random = {
            name = "paleotest_dire_wolf_howl",
            gain = 1.0,
            distance = 32
        },
        hurt = {
            name = "paleotest_dire_wolf_hurt",
            gain = 1.0,
            distance = 16
        },
        death = {
            name = "paleotest_dire_wolf_death",
            gain = 1.0,
            distance = 16
        }
    },
    -- Basic
    physical = true,
    collide_with_objects = true,
    static_save = true,
    needs_enrichment = true,
    live_birth = true,
    sleeps_at = "",
    max_hunger = 50,
    punch_cooldown = 1,
    defend_owner = true,
    targets = {},
    predators = {},
    follow = paleotest.global_meat,
    drops = {{name = "paleotest:mammal_meat_raw", chance = 1, min = 1, max = 3}},
    timeout = 0,
    logic = dire_wolf_logic,
    get_staticdata = mobkit.statfunc,
    on_activate = function(self, staticdata, dtime_s)
        paleotest.on_activate(self, staticdata, dtime_s)
        self.pack_size = mobkit.recall(self, "pack_size") or 1
        self.total_predators = mobkit.recall(self, "total_predators") or 0
    end,
    on_step = paleotest.on_step,
    on_rightclick = function(self, clicker)
        if paleotest.feed_tame(self, clicker, 10, self.child, false) then
            return
        end
        if clicker:get_wielded_item():get_name() == "paleotest:field_guide" then
            if self._pregnant and clicker:get_player_control().sneak then
                minetest.show_formspec(clicker:get_player_name(),
                                       "paleotest:pregnant_guide",
                                       paleotest.pregnant_progress_page(self))
                return
            end
            local fg_image
            if self.textures[self.texture_no]:match("black") then
                fg_image = "paleotest_dire_wolf_fg_black.png"
            elseif self.textures[self.texture_no]:match("white") then
                fg_image = "paleotest_dire_wolf_fg_white.png"
            end
            minetest.show_formspec(clicker:get_player_name(),
                                   "paleotest:dire_wolf_guide",
                                   paleotest.register_fg_entry(self, {
                image = fg_image,
                diet = "Carnivore",
                temper = "Timid or Aggressive"
            }))
        end
        if self.mood > 50 then paleotest.set_order(self, clicker) end
        mob_core.protect(self, clicker, true)
        mob_core.nametag(self, clicker)
    end,
    on_punch = function(self, puncher, _, tool_capabilities, dir)
        if puncher:get_player_control().sneak == true then
            paleotest.set_attack(self, puncher)
        else
            paleotest.on_punch(self)
            mob_core.on_punch_basic(self, puncher, tool_capabilities, dir)
            if puncher:get_player_name() == self.owner and self.mood > 50 then
                return
            end
            mob_core.on_punch_retaliate(self, puncher, false, true)
        end
    end
})

mob_core.register_spawn_egg("paleotest:dire_wolf", "a0998fcc", "3b3630d9")