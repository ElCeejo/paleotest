---------------------
-- HQ/LQ Functions --
---------------------
------ Ver 2.0 ------

------------
-- Locals --
------------

local abs = math.abs

local vec_dist = vector.distance

local function anim_length(self, anim)
	if self.animation and self.animation[anim] then
		local frame1 = self.animation[anim].range.x
		local frame2 = self.animation[anim].range.y
        local frame_length = frame2-frame1
        local total_length = frame_length/self.animation[anim].speed
		return abs(total_length)
	end
end

local function hitbox(object)
	if type(object) == "table" then
		object = object.object
	end
    return object:get_properties().collisionbox
end

local function find_closest_pos(tbl, pos)
    local iter = 2
    if #tbl < 2 then return end
    local closest = tbl[1]
    while iter < #tbl do
        if vec_dist(pos, closest) < vec_dist(pos, tbl[iter + 1]) then
            iter = iter + 1
        else
            closest = tbl[iter]
            iter = iter + 1
        end
    end
    if iter >= #tbl and closest then return closest end
end

------------------
-- LQ Functions --
------------------

-- Dumb Punch --

function paleotest.lq_dumb_punch(self, target)
	local func = function(self)
		mobkit.animate(self, "stand")
		local vel = self.object:get_velocity()
		self.object:set_velocity({x=0,y=vel.y,z=0})
		local pos = self.object:get_pos()
		local yaw = self.object:get_yaw()
		local tpos = target:get_pos()
		local tyaw = minetest.dir_to_yaw(vector.direction(pos, tpos))
		if abs(tyaw-yaw) > 0.1 then
			mobkit.turn2yaw(self, tyaw, 4)
		elseif vec_dist(pos, tpos) < self.reach-hitbox(target)[4]
		and self.punch_timer <= 0 then
			mobkit.animate(self, "punch")
			target:punch(self.object, 1.0, {
				full_punch_interval = 0.1,
				damage_groups = {fleshy = self.damage}
			}, nil)
			mob_core.punch_timer(self, self.punch_cooldown)
			return true
		end
	end
	mobkit.queue_low(self, func)
end

------------------
-- HQ Functions --
------------------

-- Latch Attack --

function paleotest.hq_latch(self,prty,target)
	local timer = 4
	local func = function(self)
        if not mobkit.is_alive(target) then
            if self.latching == target then
                mobkit.animate(self,"stand")
                self.object:set_detach()
                mobkit.clear_queue_high(self)
                self.latching = nil
                self.object:set_properties({
                    visual_size = self.base_size
                })
            end
            return true
        end
        local pos = mobkit.get_stand_pos(self)
        local tpos = mobkit.get_stand_pos(target)
		local dist = vec_dist(pos,tpos)
		if not self.latching then
			timer = timer-1
		end
		if dist <= self.collisionbox[4]+self.reach then
            if not self.latching then
                self.latching = target
                self.base_size = self.visual_size
                local target_scale = self.visual_size.x/target:get_luaentity().visual_size.x
                self.object:set_properties({
                    visual_size = {x=target_scale,y=target_scale}
                })
				self.object:set_attach(target, "", {x=0,y=target:get_luaentity().collisionbox[5],z=0}, {x=0,y=0,z=0})
				timer = 4
            end
            mobkit.animate(self,"latch")
            if mobkit.timer(self,1) then
                target:punch(self.object, 1.0, {
                    full_punch_interval = 0.1,
                    damage_groups = {fleshy = self.damage}
                }, nil)
            end
		end
		if timer <= 0 then
			mobkit.clear_queue_high(self)
			return true
		end
	end
	mobkit.queue_high(self,func,prty)
end

-- Fight and Flee --

function paleotest.hq_fight_and_flee(self, prty, target)
	local func = function(self)
		if not mobkit.is_alive(target) then return true end
		local pos = mobkit.get_stand_pos(self)
		local tpos = target:get_pos()
		if mobkit.is_queue_empty_low(self) then
			mob_core.punch_timer(self)
			if vec_dist(pos, tpos) < 8
			and self.punch_timer <= 0 then
				paleotest.lq_dumb_punch(self, target)
			end
			if vec_dist(pos, tpos) < self.view_range
			and (vec_dist(pos, tpos) > 8
			or self.punch_timer > 0) then
				local fpos = {x=2*pos.x - tpos.x,y=tpos.y,z=2*pos.z - tpos.z}
				mob_core.goto_next_waypoint(self, fpos)
			elseif vec_dist(pos, tpos) > self.view_range then
				mobkit.clear_queue_high(self)
				mobkit.lq_idle(self, 1)
				self.object:set_velocity({x=0,y=0,z=0})
				return true
			end
		end
	end
	mobkit.queue_high(self, func, prty)
end

local function eat_from_feeder(self, feeder)
    if not feeder then return end
    local node = minetest.get_node(feeder)
    local on_feed = minetest.registered_nodes[node.name].on_feed
	local meta = minetest.get_meta(feeder)
	local food_level = meta:get_int("food_level")
	local hunger = self.max_hunger - self.hunger
	if food_level - hunger >= 0 then
		self.hunger = mobkit.remember(self,"hunger",self.hunger+hunger)
        meta:set_int("food_level",food_level - hunger)
        on_feed(feeder, hunger)
		if self.hunger > self.max_hunger then
			self.hunger = mobkit.remember(self, "hunger", self.max_hunger)
		end
	else
		self.hunger = mobkit.remember(self,"hunger",self.hunger + food_level)
        meta:set_int("food_level", 0)
        on_feed(feeder, hunger)
		if self.hunger > self.max_hunger then
			self.hunger = mobkit.remember(self, "hunger", self.max_hunger)
		end
	end
end

-- Eat from Feeder --

function paleotest.hq_go_to_feeder(self, prty, search_for)
	local timer = 16
	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		local pos1 = {x=pos.x -self.view_range,y=pos.y-self.view_range,z=pos.z-self.view_range}
		local pos2 = {x=pos.x +self.view_range,y=pos.y+self.view_range,z=pos.z+self.view_range}
		local nodes = minetest.find_nodes_in_area(pos1, pos2, search_for)
		if mobkit.is_queue_empty_low(self) and self.isonground then
			local feeder
			if #nodes < 1 then
				return true
			end
			for _,i in ipairs(nodes) do
				local meta = minetest.get_meta(i)
				local food_level = meta:get_int("food_level")
				if food_level > 1 then
					feeder = i
					break
				end
			end
			if not feeder then return true end
			timer = timer - self.dtime
			if timer <= 0 then mobkit.clear_queue_high(self) end
			local meta = minetest.get_meta(feeder)
			local food_level = meta:get_int("food_level")
			if food_level < 1 then return true end
			if vec_dist(pos,feeder) > self.collisionbox[4]+2 then
				mob_core.goto_next_waypoint(self,feeder)
			else
				eat_from_feeder(self,feeder)
				paleotest.feeder_update_formspec(meta)
				paleotest.particle_spawner(feeder, "farming_bread.png", "splash")
				mobkit.lq_idle(self,1)
				return true
			end
		end
    end
    mobkit.queue_high(self,func,prty)
end

-- Eat from Aquatic Feeder --

function paleotest.hq_aqua_go_to_feeder(self,prty,search_for)
	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		local pos1 = {x=pos.x -self.view_range,y=pos.y-1,z=pos.z-self.view_range}
		local pos2 = {x=pos.x +self.view_range,y=pos.y+1,z=pos.z+self.view_range}
		local nodes = minetest.find_nodes_in_area(pos1,pos2,search_for)
		if mobkit.is_queue_empty_low(self) and self.isinliquid then
			local feeder
			if #nodes < 1 then
				return true
			end
			for _,i in ipairs(nodes) do
				local meta = minetest.get_meta(i)
				local food_level = meta:get_int("food_level")
				if food_level > 1 then
					feeder = i
					break
				end
			end
			if not feeder then return true end
			local meta = minetest.get_meta(feeder)
			local food_level = meta:get_int("food_level")
			if food_level < 1 then return true end
			if vec_dist(pos,feeder) > self.collisionbox[4]+3 then
				mob_core.swim_to_next_waypoint(self,feeder)
			else
				eat_from_feeder(self,feeder)
				paleotest.feeder_update_formspec(meta)
				paleotest.particle_spawner(feeder, "farming_bread.png", "splash")
				return true
			end
		end
    end
    mobkit.queue_high(self,func,prty)
end

-- Eat dropped items --

function paleotest.hq_eat_items(self, prty)
	local func = function(self)
		local pos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(pos, self.view_range)
		if #objs < 1 then return true end
		for _, obj in ipairs(objs) do
			local ent = obj:get_luaentity()
			if mobkit.is_queue_empty_low(self) then
				for i = 1, #self.follow do
					if ent
					and ent.name == "__builtin:item"
					and ent.itemstring:match(self.follow[i]) then
						local food = obj:get_pos()
						if vec_dist(pos, food) > self.collisionbox[4] + 2 then
							mob_core.goto_next_waypoint(self, food)
						else
							mobkit.lq_turn2pos(self, food)
							mobkit.lq_idle(self, 1, "punch")
							local stack = ItemStack(ent.itemstring)
							local max_count = stack:get_stack_max()
							local count = math.min(stack:get_count(), max_count)
							self.hunger = mobkit.remember(self, "hunger", self.hunger + count)
							obj:punch(self.object, 1.0, {
								full_punch_interval = 0.1,
								damage_groups = {}
							}, nil)
							return true
						end
					else
						return true
					end
				end
			end
		end
	end
	mobkit.queue_high(self,func,prty)
end

-- Graze from Ground --

function paleotest.hq_graze(self, prty, search_for)
    local timer = 8
	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		local pos1 = {x=pos.x-self.view_range,y=pos.y-self.view_range,z=pos.z-self.view_range}
		local pos2 = {x=pos.x+self.view_range,y=pos.y+self.view_range,z=pos.z+self.view_range}
		local food = minetest.find_nodes_in_area(pos1, pos2, search_for)
		if #food < 1 then return true end
		local go_to = find_closest_pos(pos, food)
		if mobkit.is_queue_empty_low(self)
		and self.isonground
		and go_to then
            if vec_dist(pos, go_to) > self.collisionbox[4]+1 then
                timer = timer - self.dtime
                mob_core.goto_next_waypoint(self, go_to)
                if timer <= 0 then
                    return true
                end
			else
				mobkit.lq_idle(self,0.1)
				minetest.set_node(go_to, {name="air"})
				return true
			end
		end
    end
    mobkit.queue_high(self,func,prty)
end

-- Graze from Trees --

function paleotest.hq_graze_high(self,prty,search_for,height)
    local timer = 12
	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		local pos1 = {x=pos.x-self.view_range,y=pos.y-1,z=pos.z-self.view_range}
		local pos2 = {x=pos.x+self.view_range,y=pos.y+height,z=pos.z+self.view_range}
		local food = minetest.find_nodes_in_area(pos1, pos2, search_for)
		if #food < 1 then return true end
		local go_to = find_closest_pos(pos, food)
		if mobkit.is_queue_empty_low(self)
		and self.isonground
		and go_to then
            if vec_dist(pos, go_to) > self.collisionbox[4] + self.reach then
                timer = timer - self.dtime
                mob_core.goto_next_waypoint(self, go_to)
                if timer <= 0 then
                    return true
                end
			else
				self.object:set_velocity({x=0,y=0,z=0})
				minetest.set_node(go_to, {name="air"})
				return true
			end
		end
    end
    mobkit.queue_high(self,func,prty)
end

-- Flop when out of water --

function paleotest.hq_flop(self, prty)
	local init = true
	local func = function(self)
		if self.isinliquid then return true end
		if not mobkit.is_alive(self) then return true end
		if init then
			mobkit.lq_fallover(self)
			init = false
		end
		local pos = mobkit.get_stand_pos(self)
		local yaw = self.object:get_yaw()
		local vel = self.object:get_velocity()
		local pos1 = {x=pos.x-self.view_range,y=pos.y-self.view_range/4,z=pos.z-self.view_range}
		local pos2 = {x=pos.x+self.view_range,y=pos.y+self.view_range/4,z=pos.z+self.view_range}
		local water = minetest.find_nodes_in_area(pos1, pos2, paleotest.global_liquid)
		if #water < 1 then
			if self.isonground then
				vel.y = vel.y + 6
				self.object:add_velocity(vector.multiply(vel, minetest.yaw_to_dir(yaw+math.random(0.1, 6.3))))
			end
		else
			if self.isonground then
				vel.y = vel.y + 6
				self.object:add_velocity(vector.multiply(vel, vector.direction(pos, water[1])))
			end
		end
    end
	mobkit.queue_high(self, func, prty)
end

-- Animated Roar --

function paleotest.hq_roar(self, prty)
	local init = true
	local duration = anim_length(self, "roar") or 0
	local func=function(self)
		if mobkit.is_queue_empty_low(self) then
			if init then
				mobkit.animate(self, "roar")
				init=false
				mobkit.make_sound(self,"roar")
			end
			duration = duration-self.dtime
			if duration <= 0 then return true end
		end
	end
	mobkit.queue_high(self,func,prty)
end

-----------
-- Sleep --
-----------

local function get_time()
	local time
    local timeofday = minetest.get_timeofday()
	if not timeofday then return nil end
	timeofday = timeofday  * 24000
    if timeofday < 4500 or timeofday > 19500 then
		time = "night"
	else
		time = "day"
    end
    return time
end

function paleotest.lq_go_to_sleep(self)
    local func = function(self)
		mobkit.animate(self, "sleep")
		self.status = mobkit.remember(self, "status", "sleeping")
		if not self.child
		or (self.child
		and not self.child_sleep_overlay) then
			self.object:set_texture_mod("^"..self.sleep_overlay)
		else
			self.object:set_texture_mod("^"..self.child_sleep_overlay)
		end
		mobkit.clear_queue_low(self)
        return true
    end
    mobkit.queue_low(self,func)
end

function paleotest.lq_wakeup(self)
    local func = function(self)
        mobkit.animate(self, "stand")
		self.status = mobkit.remember(self, "status", "")
		self.object:set_texture_mod("")
        mobkit.clear_queue_high(self)
        mobkit.clear_queue_low(self)
        return true
    end
    mobkit.queue_low(self,func)
end

function paleotest.hq_sleep(self, prty)
    local func = function(self)
		local time = get_time()
        if self.status ~= "sleeping"
        and time ~= self.sleeps_at then
            self.sleep_timer = mobkit.remember(self, "sleep_timer", 10)
            return true
        end
        if self.status ~= "sleeping"
        and time == self.sleeps_at then
            paleotest.lq_go_to_sleep(self)
        end
        if self.status == "sleeping"
		and time == self.sleeps_at then
			if not self.child
			or (self.child
			and not self.child_sleep_overlay) then
				self.object:set_texture_mod("^"..self.sleep_overlay)
			else
				self.object:set_texture_mod("^"..self.child_sleep_overlay)
			end
            mobkit.animate(self, "sleep")
        end
        if self.status == "sleeping"
		and time ~= self.sleeps_at then
            paleotest.lq_wakeup(self)
        end
    end
    mobkit.queue_high(self, func, prty)
end

-------------
-- Playing --
-------------

function paleotest.logic_play_with_ball(self, prty)
	local func = function(self)
		local pos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(pos, self.view_range)
		if #objs < 1 then return true end
		for _, obj in ipairs(objs) do
			if obj:get_luaentity()
			and obj:get_luaentity().name == "paleotest:pursuit_ball_ent" then
				if mobkit.is_queue_empty_low(self) then
					local obj_pos = obj:get_pos()
					if vec_dist(pos, obj_pos) > self.collisionbox[4] + self.reach then
						mob_core.goto_next_waypoint(self, obj_pos)
					else
						mobkit.lq_turn2pos(self, obj_pos)
						mobkit.lq_idle(self, 1, "punch")
						obj:punch(self.object, 1.0, {
							full_punch_interval = 0.1,
							damage_groups = {}
						}, nil)
						if self.mood < 100 then
							self.mood = mobkit.remember(self, "mood", self.mood + 5)
						else
							self.mood = mobkit.remember(self, "mood", 100)
						end
						return true
					end
				end
			else
				return true
			end
		end
	end
	mobkit.queue_high(self,func,prty)
end

function paleotest.logic_play_with_post(self,prty)
	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		local pos1 = {x=pos.x -self.view_range,y=pos.y-1,z=pos.z-self.view_range}
		local pos2 = {x=pos.x +self.view_range,y=pos.y+1,z=pos.z+self.view_range}
		local post = minetest.find_nodes_in_area(pos1,pos2,"paleotest:scratching_post")
		if #post < 1 then return end
		local go_to = find_closest_pos(pos, post)
		if mobkit.is_queue_empty_low(self)
		and self.isonground
		and go_to then
			if vec_dist(pos, go_to) > self.collisionbox[4]+1.5 then
				mob_core.goto_next_waypoint(self, go_to)
			else
				mobkit.lq_idle(self, 1, "punch")
				paleotest.particle_spawner(self.object:get_pos(), "heart.png", "float")
				if self.mood < 100 then
					self.mood = mobkit.remember(self,"mood",self.mood+5)
				else
					self.mood = mobkit.remember(self,"mood",100)
				end
				return true
			end
		end
		return true
    end
    mobkit.queue_high(self,func,prty)
end


--------------------
-- Fight and Flee --
--------------------

function paleotest.logic_flee_or_fight(self, prty) -- Attack specified mobs
    if self.predators then
        for i = 1, #self.predators do
            local predator = mobkit.get_closest_entity(self, self.predators[i])
            if predator
            and vec_dist(self.object:get_pos(), predator:get_pos()) < self.view_range
            and mobkit.is_alive(predator) then
                if (self.tamed == true and predator:get_luaentity().owner ~= self.owner)
                or not self.tamed then
                    paleotest.hq_fight_and_flee(self, prty, predator)
                    return
                end
            end
        end
    end
end

------------------
-- Aerial Mount --
------------------

function paleotest.hq_aerial_mount_logic(self, prty)
    local forward_speed = minetest.registered_entities[self.name].max_speed_forward
    local y = 0
    local tvel = 0
    local jump_meter = 0
    local last_pos = {}
    local mount_state = "ground"
    local anim = "stand"
    local timer = 0.25
    local init = false
    local func = function(self)
        if not self.driver then return true end
        if not init then
            self.driver:set_attach(self.object, "Torso.2", self.driver_attach_at, self.player_rotation)
        end
        local pos = mobkit.get_stand_pos(self)

        if timer <= 0 then
            last_pos = pos
            timer = 0.25
        end

        local ctrl = self.driver:get_player_control()
        local tyaw = self.driver:get_look_horizontal() or 0
        local yaw = self.object:get_yaw()
        local cur_vel = self.object:get_velocity()

        if math.abs(tyaw - yaw) > 0.1 then self.object:set_yaw(tyaw) end
        local vel = vector.multiply(minetest.yaw_to_dir(yaw), tvel)
        vel.y = y

        self.object:set_velocity(vel)

        if mount_state == "ground" then

            -- Move Forward
            if ctrl.up then
                tvel = forward_speed/3
            end

            -- Jump
            if ctrl.jump then
                if self.isonground then
                    y = (self.jump_height) + 4
                end
                jump_meter = jump_meter + self.dtime
                if jump_meter > 0.5 then -- Takeoff
                    y = 6
                    mount_state = "flight"
                end
            else
                jump_meter = 0
                y = cur_vel.y
            end

            if tvel > 0 then
                anim = "walk"
            else
                anim = "stand"
            end
        end

        if mount_state == "flight" then

            tvel = forward_speed

            if ctrl.down then
                y = -forward_speed
                pos.y = pos.y - 1
                timer = timer - self.dtime
                if timer <= 0 and last_pos and last_pos.y == pos.y then
                    mount_state = "ground"
                end
            elseif ctrl.jump then
                y = forward_speed
            elseif not ctrl.jump and not ctrl.down then
                y = 0
            end

            if self.object:get_acceleration().y < 0 then
                self.object:set_acceleration({x = 0, y = 0, z = 0}) -- Defy Gravity
            end

            anim = "fly"

        end

        mobkit.animate(self, anim)

        -- Velocity Control

        if mount_state == "ground"
        and tvel ~= 0
        and not ctrl.up then tvel = 0 end

        if not ctrl.down and not ctrl.jump then
            if mount_state == "ground" then
                y = cur_vel.y
            else
                y = 0
            end
        end

        if ctrl.sneak then
            mobkit.clear_queue_low(self)
            mobkit.clear_queue_high(self)
            mob_core.detach(self.driver, {x = -1, y = 0, z = 0})
        end
    end
    mobkit.queue_high(self, func, prty)
end

-------------------
-- Aerial Follow --
-------------------

function paleotest.hq_aerial_follow(self, prty, target)
    local center = self.object:get_pos()
    local timer = 5
    local func = function(self)
        if not mobkit.is_alive(target) then
            return true
        end
        if mobkit.is_queue_empty_low(self) and not self.isinliquid then
            local pos = mobkit.get_stand_pos(self)
            local pos2 = target:get_pos()
            if vector.distance(pos, pos2) > 12 then
                timer = timer - self.dtime
            end
            if timer <= 0
            and vector.distance(pos, center) < 12 then
                self.object:add_velocity({x = 0, y = 2, z = 0})
            end
            if self.isonground then
                if pos2.y - pos.y > 4 then
                    self.object:add_velocity({x = 0, y = 2, z = 0})
                end
                if vector.distance(pos, pos2) > 1.5*self.growth_stage then
                    mob_core.goto_next_waypoint(self, pos2)
                else
                    mobkit.lq_idle(self, 1)
                end
            end
            if not self.isonground then
                mob_core.fly_to_next_waypoint(self, pos2)
            end
        end
    end
    mobkit.queue_high(self, func, prty)
end
