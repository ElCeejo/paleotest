----------------
-- Thylacoleo --
----------------

local function set_mob_tables(self)
    for _, entity in pairs(minetest.luaentities) do
        local name = entity.name
        if name ~= self.name and
            paleotest.find_string(paleotest.mobkit_mobs, name) then
            local height = entity.height
            if not paleotest.find_string(self.targets, name) and height and
                height < 2 then
                if entity.object:get_armor_groups() and
                    entity.object:get_armor_groups().fleshy then
                    table.insert(self.targets, name)
                elseif entity.name:match("^petz:") then
                    table.insert(self.targets, name)
                end
                if entity.targets and
                    paleotest.find_string(entity.targets, self.name) then
                    if entity.object:get_armor_groups() and
                        entity.object:get_armor_groups().fleshy then
                        table.insert(self.predators, name)
                    end
                end
            end
        end
    end
end

local function thylacoleo_logic(self)

    if self.hp <= 0 then
        mob_core.on_die(self)
        return
    end

    set_mob_tables(self)

    local prty = mobkit.get_queue_priority(self)
    local player = mobkit.get_nearby_player(self)

    if mobkit.timer(self, 1) then

        if self.order == "stand" and self.mood > 50 then
            mobkit.animate(self, "stand")
            return
        end

        if prty < 18 and self.isinliquid then
            mob_core.hq_liquid_recovery(self, 18, "walk")
            return
        end

        if prty < 16 and self.owner_target then
            mob_core.logic_attack_mob(self, 16, self.owner_target)
        end

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
                    mob_core.logic_attack_mobs(self, 12)
                end
                if self.mood < 50 or not self.tamed then
                    mob_core.logic_attack_mobs(self, 12)
                end
                if #self.predators > 0 then
                    mob_core.logic_attack_mobs(self, 12, self.predators)
                end
            end
        end

        if prty < 10 then
            if self.status == "sleeping" then return end
            if player and not self.child then
                if (self.attacks == "players" or self.attacks == "all") and
                    player:get_player_name() ~= self.owner then
                    mob_core.logic_attack_player(self, 10, player)
                end
                if self.mood > 50 and player:get_player_name() ~= self.owner then
                    mob_core.logic_attack_player(self, 10, player)
                elseif self.mood < 50 then
                    mob_core.logic_attack_player(self, 10, player)
                end
            end
        end

        if prty < 8 then
            if self.status == "sleeping" then return end
            if self.mood > 50 then
                mob_core.hq_follow_holding(self, 8, player)
            end
        end

        if prty < 6 then
            if self.status == "sleeping" then return end
            if math.random(1, self.mood) == 1 then
                if paleotest.can_find_post(self) then
                    paleotest.logic_play_with_post(self, 6)
                elseif paleotest.can_find_ball(self) then
                    paleotest.logic_play_with_ball(self, 6)
                end
            end
        end

        if prty < 4 then
            if self.sleep_timer <= 0 and self.status ~= "following" then
                paleotest.hq_sleep(self, 4)
            end
        end

        if mobkit.is_queue_empty_high(self) then
            mob_core.hq_roam(self, 0)
        end
    end
end

minetest.register_entity("paleotest:thylacoleo", {
    -- Stats
    max_hp = 32,
    armor_groups = {fleshy = 100},
    view_range = 16,
    reach = 5,
    damage = 6,
    knockback = 4,
    lung_capacity = 30,
    -- Movement & Physics
    max_speed = 6,
    stepheight = 1.26,
    jump_height = 1.26,
    max_fall = 8,
    buoyancy = 0.25,
    springiness = 0,
    -- Visual
    collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.45, 0.3},
    visual_size = {x = 8, y = 8},
    scale_stage1 = 0.45,
    scale_stage2 = 0.65,
    scale_stage3 = 0.85,
    visual = "mesh",
    mesh = "paleotest_thylacoleo.b3d",
    female_textures = {"paleotest_thylacoleo_female.png"},
    male_textures = {"paleotest_thylacoleo_male.png"},
    child_textures = {"paleotest_thylacoleo_child.png"},
    sleep_overlay = "paleotest_thylacoleo_eyes_closed.png",
    animation = {
        walk = {range = {x = 1, y = 40}, speed = 20, loop = true},
        run = {range = {x = 1, y = 40}, speed = 25, loop = true},
        stand = {range = {x = 50, y = 90}, speed = 15, loop = true},
        punch = {range = {x = 100, y = 130}, speed = 25, loop = false},
        sleep = {range = {x = 140, y = 160}, speed = 5, loop = true}
    },
    -- Sound
    sounds = {
        alter_child_pitch = true,
        random = {
            name = "paleotest_thylacoleo_idle",
            gain = 1.0,
            distance = 16
        },
        hurt = {
            name = "paleotest_thylacoleo_hurt",
            gain = 1.0,
            distance = 16
        },
        death = {
            name = "paleotest_thylacoleo_death",
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
    punch_cooldown = 0.2,
    defend_owner = true,
    targets = {},
    predators = {},
    rivals = {},
    follow = paleotest.global_meat,
    drops = {{name = "paleotest:mammal_meat_raw", chance = 1, min = 1, max = 3}},
    timeout = 0,
    logic = thylacoleo_logic,
    get_staticdata = mobkit.statfunc,
    on_activate = paleotest.on_activate,
    on_step = paleotest.on_step,
    on_rightclick = function(self, clicker)
        if paleotest.feed_tame(self, clicker, 10, self.child, true) then return end
        if clicker:get_wielded_item():get_name() == "paleotest:field_guide" then
            if self._pregnant and clicker:get_player_control().sneak then
                minetest.show_formspec(clicker:get_player_name(),
                                       "paleotest:pregnant_guide",
                                       paleotest.pregnant_progress_page(self))
                return
            end
            minetest.show_formspec(clicker:get_player_name(),
                                   "paleotest:thylacoleo_guide",
                                   paleotest.register_fg_entry(self, {
                female_image = "paleotest_thylacoleo_fg_female.png",
                male_image = "paleotest_thylacoleo_fg_male.png",
                diet = "Carnivore",
                temper = "Neutral"
            }))
        end
        paleotest.set_order(self, clicker)
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

mob_core.register_spawn_egg("paleotest:thylacoleo", "977761cc", "6a4d3fd9")
