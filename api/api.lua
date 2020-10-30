-------------------
-- PaleoTest API --
-------------------
----- Ver 2.0 -----

local function find_feeder(self, feeder)
    local pos = self.object:get_pos()
    local pos1 = {x = pos.x + 32, y = pos.y + 32, z = pos.z + 32}
    local pos2 = {x = pos.x - 32, y = pos.y - 32, z = pos.z - 32}
    local area = minetest.find_nodes_in_area(pos1, pos2, feeder)
    if #area < 1 then return false end
    return true
end

local random = math.random

local creative = minetest.settings:get_bool("creative_mode")

function paleotest.particle_spawner(pos, texture, type)
	type = type or "float"
	if type == "float" then
		minetest.add_particlespawner({
			amount = 16,
			time = 0.25,
			minpos = {
				x = pos.x - 2,
				y = pos.y - 2,
				z = pos.z - 2,
			},
			maxpos = {
				x = pos.x + 2,
				y = pos.y + 2,
				z = pos.z + 2,
			},
			minacc = {x = 0, y = 0.25, z = 0},
			maxacc = {x = 0, y = -0.25, z = 0},
			minexptime = 0.75,
			maxexptime = 1,
			minsize = 4,
			maxsize = 4,
			texture = texture,
			glow = 1,
		})
	elseif type == "splash" then
		minetest.add_particlespawner({
			amount = 6,
			time = 0.25,
			minpos = {x = pos.x - 7/16, y = pos.y + 0.6, z = pos.z - 7/16},
			maxpos = {x = pos.x + 7/16, y = pos.y + 0.6, z = pos.z + 7/16},
			minvel = vector.new(-1, 2, -1),
			maxvel = vector.new(1, 5, 1),
			minacc = vector.new(0, -9.81, 0),
			maxacc = vector.new(0, -9.81, 0),
			minsize = 2,
			maxsize = 4,
			collisiondetection = true,
			texture = texture,
		})
	end
end

-----------------
-- On Activate --
-----------------

function paleotest.on_activate(self, staticdata, dtime_s)
	mob_core.on_activate(self, staticdata, dtime_s)
	self.is_in_shallow = false
	self.mood = mobkit.recall(self, "mood") or 75
	self.hunger = mobkit.recall(self, "hunger") or self.max_hunger/2
	self.sleep_timer = mobkit.recall(self, "sleep_timer") or 1
	self.order = mobkit.recall(self, "order") or "wander"
	self.attacks = mobkit.recall(self, "attacks") or "nothing"
	self.feeder_timer = mobkit.recall(self, "feeder_timer") or 32
	self.imprinter = mobkit.recall(self, "imprinter") or nil
	self.imprint_cooldown = mobkit.recall(self, "imprint_cooldown") or 1200
	self.imprint_exp_timer = mobkit.recall(self, "imprint_exp_timer") or 1200
	self.imprint_level = mobkit.recall(self, "imprint_level") or 0
	self.can_imprint = mobkit.recall(self, "can_imprint") or false
end


-------------
-- On Step --
-------------

function paleotest.on_step(self, dtime, moveresult)
	mobkit.stepfunc(self, dtime)
	self.moveresult = moveresult
	if not mobkit.is_alive(self) then return end
	mob_core.collision_detection(self)
	-- Vitals and other Functions
	if mobkit.timer(self, 1) then -- 1 Second Timer
		mob_core.vitals(self)
		mob_core.random_sound(self)
		mob_core.growth(self)
		paleotest.breed(self, self.live_birth)
		if self.sleep_timer > 0 then
			self.sleep_timer = mobkit.remember(self, "sleep_timer", self.sleep_timer-1)
		end
		if self.imprint_tame
		and not self.tamed
		or (self.growth_stage == 4
		and self.imprint_exp_timer > 0) then
			if self.imprint_cooldown >= 0 then
				self.imprint_cooldown = self.imprint_cooldown - 1
				self.can_imprint = false
			else
				self.imprint_exp_timer = self.imprint_exp_timer - 1
			end
			if self.imprint_cooldown <= 0 then
				self.can_imprint = true
			end
			if self.imprint_exp_timer <= 0 then
				self.can_imprint = false
				self.imprint_level = 0
			end
			mobkit.remember(self, "imprint_cooldown", self.imprint_cooldown)
			mobkit.remember(self, "imprint_exp_timer", self.imprint_exp_timer)
			mobkit.remember(self, "imprint_level", self.imprint_level)
			mobkit.remember(self, "can_imprint", self.can_imprint)
		end
	end
	-- Keep track of hunger and mood
	if self.needs_enrichment then
		if self.mood > 100 then
			self.mood = 100
		end
		if mobkit.timer(self, 60) then
			if self.status == "sleeping"
			and self.hunger > self.max_hunger/3
			and self.mood < 100 then
				self.mood = self.mood + 1
			end
		end
	end
	if self.hunger > self.max_hunger then
		self.hunger = self.hunger - 1
	end
	if mobkit.timer(self, 120) then
		self.hunger = self.hunger - 1
	end
	if mobkit.timer(self, 1) then
		if self.feeder_timer > 0 then
			self.feeder_timer = self.feeder_timer - 1
		elseif self.feeder_timer <= 0 then
			self.feeder_timer = mobkit.remember(self, "feeder_timer", random(16, 64))
		end
		if self.hunger < self.max_hunger/3 then
			if self.needs_enrichment then
				if self.mood > 0 then
					self.mood = self.mood - 1
				else
					self.mood = 0
				end
			end
			if self.hp >= self.max_hp/4 then
				mobkit.hurt(self, 1)
			end
		end
	end
	if mobkit.recall(self, "hunger") ~= self.hunger then
		mobkit.remember(self, "hunger", self.hunger)
	end
	if mobkit.recall(self, "mood") ~= self.mood then
		mobkit.remember(self, "mood", self.mood)
	end
	
	-- Check if in shallow water
	local pos = mobkit.get_stand_pos(self)
	local half_height = vector.new(pos.x, pos.y + self.height/2, pos.z)
	local height = vector.new(pos.x, pos.y + self.height, pos.z)
	if self.isinliquid
	and minetest.get_node(half_height) ~= self.isinliquid then
		self.is_in_shallow = true
		self.is_in_deep = true
	elseif self.isinliquid
	and minetest.get_node(height) == self.isinliquid then
		self.is_in_shallow = false
		self.is_in_deep = true
	else
		self.is_in_shallow = false
		self.is_in_deep = false
	end
end

local function hitbox(ent)
	if type(ent) == 'userdata' then
		return  ent:get_properties().collisionbox
	end
    return ent.object:get_properties().collisionbox
end

function paleotest.feed_tame(self, clicker, feed_count, tame, breed)
	local item = clicker:get_wielded_item()
	local pos = self.object:get_pos()
	local mob_name = mob_core.get_name_proper(self.name)
	if mob_core.follow_holding(self, clicker) then
		if creative == false then
			item:take_item()
			clicker:set_wielded_item(item)
		end
		mobkit.heal(self, self.max_hp/feed_count)
		if self.hp >= self.max_hp then
			self.hp = self.max_hp
		end
		if self.hunger < self.max_hunger then
			self.food = mobkit.remember(self, "food", self.food + 1)
			if self.hunger < self.max_hunger then
				self.hunger = mobkit.remember(self,"hunger",self.hunger+5)
			elseif self.hunger >= self.max_hunger then
				self.hunger = mobkit.remember(self,"hunger",self.max_hunger)
			end
			local minppos = vector.add(pos, hitbox(self)[4])
            local maxppos = vector.subtract(pos, hitbox(self)[4])
            local def = minetest.registered_items[item:get_name()]
            local texture = def.inventory_image
            if not texture or texture == "" then
				texture = def.wield_image
				if def.tiles then
					texture = def.tiles[1]
				end
            end
            minetest.add_particlespawner({
                amount = 12*self.height,
                time = 0.1,
                minpos = minppos,
                maxpos = maxppos,
                minvel = {x=-1, y=1, z=-1},
                maxvel = {x=1, y=2, z=1},
                minacc = {x=0, y=-5, z=0},
                maxacc = {x=0, y=-9, z=0},
                minexptime = 1,
                maxexptime = 1,
                minsize = 2*self.height,
                maxsize = 3*self.height,
                collisiondetection = true,
                vertical = false,
                texture = texture,
            })
			if self.food >= feed_count then
				self.food = mobkit.remember(self, "food", 0)
				if tame and not self.tamed then
					mob_core.set_owner(self, clicker:get_player_name())
					minetest.chat_send_player(clicker:get_player_name(), mob_name.." has been tamed!")
					mobkit.clear_queue_high(self)
					paleotest.particle_spawner(pos, "mob_core_green_particle.png", "float")
				end
				if breed then
					if self.child then return false end
					if self.breed_mode then return false end
					if self.breed_timer == 0 and self.breed_mode == false then
						self.breed_mode = true
						paleotest.particle_spawner(pos, "heart.png", "float")
					end
				end
			end
		end
	end
	return false
end

------------
-- Basics --
------------

function paleotest.can_find_ball(self)
	local objects = minetest.get_objects_inside_radius(self.object:get_pos(), self.view_range)
	for _, object in ipairs(objects) do
		if object:get_luaentity() then
			local ent = object:get_luaentity()
			if ent.name
			and ent.name == "paleotest:pursuit_ball_ent" then
				return true
			end
		end
	end
	return false
end

function paleotest.can_find_post(self)
	local pos = self.object:get_pos()
	local pos1 = vector.new(pos.x - self.view_range, pos.y - self.view_range, pos.z - self.view_range)
	local pos2 = vector.new(pos.x + self.view_range, pos.y + self.view_range, pos.z + self.view_range)
	local nodes = minetest.find_nodes_in_area(pos1, pos2, "paleotest:scratching_post")
	if #nodes >= 1 then return true end
	return false
end

function paleotest.on_punch(self)
	if self.mood > 0 then
		self.mood = self.mood - 5
	elseif self.mood <= 0 then
		self.mood = 0
	end
	mobkit.remember(self, "mood", self.mood)
	if self.status == "sleeping" then
		self.status = mobkit.remember(self, "status", "")
		self.sleep_timer = mobkit.remember(self, "sleep_timer", self.sleep_timer+30)
	end
end

-----------------------
-- Tamed Mob Control --
-----------------------

local function set_order(self,player,order)
	if order == "stand" then
		if self.isinliquid then return end
		if self.status == "sleeping" then
			self.object:settexturemod("")
		end
		mobkit.clear_queue_high(self)
		mobkit.clear_queue_low(self)
		self.object:set_velocity({ x = 0, y = 0, z = 0 })
		self.object:set_acceleration({ x = 0, y = 0, z = 0 })
		self.status = mobkit.remember(self, "status", "stand")
		self.order = mobkit.remember(self, "order", "stand")
		mobkit.animate(self,"stand")
	end
	if order == "wander" then
		mobkit.clear_queue_high(self)
		mobkit.clear_queue_low(self)
		self.status = mobkit.remember(self, "status", "")
		self.order = mobkit.remember(self, "order", "wander")
	end
	if order == "follow" then
		if self.status == "sleeping" then
			self.object:settexturemod("")
		end
		mobkit.clear_queue_low(self)
		self.status = mobkit.remember(self, "status", "following")
		self.order = mobkit.remember(self, "order", "follow")
		mobkit.hq_follow(self, 15, player)
	end
end

function paleotest.set_order(self,player)
	local name = player:get_player_name()
	local mob_name = mob_core.get_name_proper(self.name)
	if self.owner and self.owner == name and player:get_player_control().sneak == true then
		if self.order == "follow" then
			set_order(self,player,"stand")
			minetest.chat_send_player(name, (""..mob_name.." is standing."))
		elseif self.order == "stand" then
			set_order(self,player,"wander")
			minetest.chat_send_player(name, (""..mob_name.." is wandering."))
		elseif self.order == "wander" then
			set_order(self,player,"follow")
			minetest.chat_send_player(name, (""..mob_name.." is following."))
		end
	end
end

function paleotest.set_attack(self, player)
	local name = player:get_player_name()
	if self.owner and self.owner == name then
		if self.attacks == "nothing" then
			self.attacks = mobkit.remember(self,"attacks","mobs")
			minetest.chat_send_player(name, ("Attacks: Mobs"))
		elseif self.attacks == "mobs" then
			self.attacks = mobkit.remember(self,"attacks","players")
			minetest.chat_send_player(name, ("Attacks: Players"))
		elseif self.attacks == "players" then
		    self.attacks = mobkit.remember(self,"attacks","all")
			minetest.chat_send_player(name, ("Attacks: All"))
		else
			self.attacks = mobkit.remember(self,"attacks","nothing")
			minetest.chat_send_player(name, ("Attacks: Nothing"))
		end
	end
end

--------------
-- Breeding --
--------------

local breeding = minetest.settings:get_bool("breeding")

function paleotest.breed(self, live) -- Breeding
	if not breeding then return end
    if self.breed_timer > 0 then
		self.breed_timer = mobkit.remember(self,"breed_timer",self.breed_timer - 1)
    else
        self.breed_timer = mobkit.remember(self,"breed_timer",0)
	end
	local name = self.name:split(":")[2]
	if self.gender == "female" then
		local pos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(pos, self.collisionbox[4]*4)
		for _,obj in ipairs(objs) do
			local luaent = obj:get_luaentity()
			if (obj and obj ~= self.object)
			and (luaent and luaent.name == self.name)
			and (self.breed_timer and luaent.breed_timer)
			and (self.breed_timer <= 0 and luaent.breed_timer <= 0)
			and (self.owner == luaent.owner) then
				self.breed_timer = mobkit.remember(self,"breed_timer",math.random(600,1200))
				luaent.breed_timer = mobkit.remember(luaent,"breed_timer",math.random(600,1200))
				minetest.after(2.5,function()
					if live then
						mob_core.spawn_child(pos,self.name)
					else
						minetest.add_entity(pos,"paleotest:egg_"..name.."_ent")
					end
					paleotest.particle_spawner(self.object:get_pos(), "heart.png", "float")
				end)
			end
		end
	end
end

function paleotest.imprint_tame(self, clicker)
	if not self.imprinter then
		self.imprinter = mobkit.remember(self, "imprinter", clicker:get_player_name())
	end
	local name = clicker:get_player_name()
	if name ~= self.imprinter
	or self.tamed
	or not self.can_imprint
	or (self.growth_stage == 4
	and not self.can_imprint) then
		return
	end
	local mob_name = mob_core.get_name_proper(self.name)
	if self.can_imprint then
		paleotest.particle_spawner(self.object:get_pos(), "heart.png", "float")
		local level = self.imprint_level
		if not level then
			self.imprint_level = 1
		else
			self.imprint_level = self.imprint_level + 1
		end
		if level == 4 then
			minetest.chat_send_player(name, mob_name .. " has been tamed")
			mob_core.set_owner(self, clicker:get_player_name())
		else
			minetest.chat_send_player(name, "Imprinting has been raised, come back in 20 minutes.")
		end
		self.can_imprint = false
		self.imprint_cooldown = 1200
		self.imprint_exp_timer = 1200
	end
	mobkit.remember(self, "imprint_level", self.imprint_level)
	mobkit.remember(self, "can_imprint", self.can_imprint)
end

--------------------
-- Block Breaking --
--------------------

local block_breaking = minetest.settings:get_bool("block_breaking")

local function can_break(pos)
	local node = minetest.get_node_or_nil(pos)
	if node
	and not minetest.registered_nodes[node.name].groups.stone
	and not minetest.registered_nodes[node.name].groups.level
	and not minetest.registered_nodes[node.name].groups.unbreakable
	and not minetest.registered_nodes[node.name].groups.liquid then
		return true
	end
end

function paleotest.block_breaking(self)
	if not block_breaking then
		return
	end
	local width = self.object:get_properties().collisionbox[4] + 0.25
	local height = self.height + 0.25
	local pos = mobkit.get_stand_pos(self)
	local pos1 = {x = pos.x + width, y = pos.y + height, z = pos.z + width}
	local pos2 = {x = pos.x - width, y = pos.y, z = pos.z - width}
	local area = minetest.find_nodes_in_area(pos1, pos2, paleotest.global_walkable)
	if #area < 1 then return end
	for i = #area, 1, -1 do
		local name = minetest.get_node(area[i]).name
		if minetest.registered_nodes[name].groups.soil
		and area[i].y < pos.y + 1.1 then -- This helps prevent terrain destruction
			table.remove(area, i)
		else
			local yaw = self.object:get_yaw()
			local yaw_to_node = minetest.dir_to_yaw(vector.direction(pos, area[i]))
			if math.abs(yaw - yaw_to_node) <= 1
			and can_break(area[i])
			and not minetest.is_protected(area[i], "") then
				if random(1, 4) == 1 then
					minetest.dig_node(area[i])
				else
					minetest.dig_node(area[i])
				end
			end
		end
	end
end