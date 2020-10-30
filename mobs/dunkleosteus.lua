------------------
-- Dunkleosteus --
------------------

local function set_mob_tables(self)
    for _, entity in pairs(minetest.luaentities) do
        local name = entity.name
        if name ~= self.name and
            paleotest.find_string(paleotest.mobkit_mobs, name) then
            local height = entity.height
            if not paleotest.find_string(self.targets, name)
            and (height and height < 1.5)
            and (entity.bouyancy and entity.bouyancy > 0.75) then
                if entity.object:get_armor_groups() and
                    entity.object:get_armor_groups().fleshy then
                    table.insert(self.targets, name)
                elseif entity.name:match("^petz:") then
                    table.insert(self.targets, name)
                end
            end
        end
    end
end

local function dunkleosteus_logic(self)

    if self.hp <= 0 then
        mob_core.on_die(self)
        return
    end

    set_mob_tables(self)

    local prty = mobkit.get_queue_priority(self)
    local player = mobkit.get_nearby_player(self)

    if mobkit.timer(self, 1) then

        if prty < 10 and not self.isinliquid then
            paleotest.hq_flop(self, 10)
            return
        end

        if prty < 8 and self.hunger < self.max_hunger then
            if self.feeder_timer == 1 then
                paleotest.hq_aqua_go_to_feeder(self, 8,
                                               "paleotest:feeder_piscivore")
            end
        end

        if prty < 6 then
            if self.hunger < self.max_hunger / 1.25 then
                mob_core.logic_aqua_attack_mobs(self, 6)
            end
        end

        if prty < 4 then
            if player then
                if self.child then return end
                mob_core.logic_aqua_attack_player(self, 4, player)
            end
        end

        if mobkit.is_queue_empty_high(self) then
            mob_core.hq_aqua_roam(self, 0, 0.8, 3, 12)
        end
    end
end

minetest.register_entity("paleotest:dunkleosteus", {
    -- Stats
    max_hp = 45,
    armor_groups = {fleshy = 80},
    view_range = 16,
    reach = 3,
    damage = 6,
    knockback = 2,
    -- Movement & Physics
    max_speed = 6,
    stepheight = 1.26,
    jump_height = 1.26,
    buoyancy = 1,
    springiness = 0,
    obstacle_avoidance_range = 1.5,
    surface_avoidance_range = 2,
    floor_avoidance_range = 2,
    -- Visual
    collisionbox = {-1.15, -0.3, -1.15, 1.15, 1.0, 1.15},
    visual_size = {x = 25, y = 25},
    scale_stage1 = 0.25,
    scale_stage2 = 0.5,
    scale_stage3 = 0.75,
    visual = "mesh",
    mesh = "paleotest_dunkleosteus.b3d",
    textures = {"paleotest_dunkleosteus.png"},
    animation = {
        swim = {range = {x = 1, y = 40}, speed = 30, loop = true},
        run = {range = {x = 1, y = 40}, speed = 35, loop = true},
        punch = {range = {x = 50, y = 70}, speed = 15, loop = false}
    },
    -- Basic
    physical = true,
    collide_with_objects = true,
    static_save = true,
    needs_enrichment = false,
    live_birth = true,
    max_hunger = 100,
    punch_cooldown = 1,
    defend_owner = false,
    targets = {},
    follow = paleotest.global_fish,
    drops = {{name = "paleotest:fish_meat_raw", chance = 1, min = 1, max = 3}},
    timeout = 0,
    logic = dunkleosteus_logic,
    get_staticdata = mobkit.statfunc,
    on_activate = paleotest.on_activate,
    on_step = paleotest.on_step,
    on_rightclick = function(self, clicker)
        if paleotest.feed_tame(self, clicker, 10, false, false) then
            return
        end
        if clicker:get_wielded_item():get_name() == "paleotest:field_guide" then
            minetest.show_formspec(clicker:get_player_name(),
                                   "paleotest:dunkleosteus_guide",
                                   paleotest.register_fg_entry(self, {
                image = "paleotest_dunkleosteus_fg.png",
                diet = "Piscivore",
                temper = "Aggressive"
            }))
        end
        mob_core.protect(self, clicker, true)
        mob_core.nametag(self, clicker)
    end,
    on_punch = function(self, puncher, _, tool_capabilities, dir)
        paleotest.on_punch(self)
        mob_core.on_punch_basic(self, puncher, tool_capabilities, dir)
        mob_core.on_punch_retaliate(self, puncher, true, false)
    end
})

mob_core.register_spawn_egg("paleotest:dunkleosteus", "495863cc", "262d34d9")
