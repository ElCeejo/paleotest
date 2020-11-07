---------------------
-- PaleoTest Items --
---------------------
------ Ver 2.0 ------

local creative = minetest.settings:get_bool("creative")

----------
-- Whip --
----------

minetest.register_tool("paleotest:whip", {
	description = "Whip",
	inventory_image = "paleotest_whip.png",
	wield_image = "paleotest_whip.png^[transformFYR90",
	groups = {flammable = 1},
})

-----------------
-- Field Guide --
-----------------

minetest.register_craftitem("paleotest:field_guide", {
	description = "Prehistoric Field Guide",
	inventory_image = "paleotest_field_guide.png",
	wield_image = "paleotest_field_guide.png",
	groups = {flammable = 1, book = 1}
})

-----------
-- Drops --
-----------

-- Dinosaur Meat --

minetest.register_craftitem("paleotest:dinosaur_meat_raw", {
	description = "Raw Dinosaur Meat",
	inventory_image = "paleotest_dinosaur_meat_raw.png",
	groups = {eatable = 1, meat = 1, raw = 1},
	on_use = minetest.item_eat(2)
})

minetest.register_craftitem("paleotest:dinosaur_meat_cooked", {
	description = "Cooked Dinosaur Meat",
	inventory_image = "paleotest_meat_cooked.png",
	groups = {eatable = 1, meat = 1, cooked = 1},
	on_use = minetest.item_eat(8)
})

-- Reptile Meat --

minetest.register_craftitem("paleotest:reptile_meat_raw", {
	description = "Raw Reptile Meat",
	inventory_image = "paleotest_dinosaur_meat_raw.png",
	groups = {eatable = 1, meat = 1, raw = 1},
	on_use = minetest.item_eat(2)
})

minetest.register_craftitem("paleotest:reptile_meat_cooked", {
	description = "Cooked Reptile Meat",
	inventory_image = "paleotest_meat_cooked.png",
	groups = {eatable = 1, meat = 1, cooked = 1},
	on_use = minetest.item_eat(8)
})

-- Mammal Meat --

minetest.register_craftitem("paleotest:mammal_meat_raw", {
	description = "Raw Mammal Meat",
	inventory_image = "paleotest_mammal_meat_raw.png",
	groups = {eatable = 1, meat = 1, raw = 1},
	on_use = minetest.item_eat(2)
})

minetest.register_craftitem("paleotest:mammal_meat_cooked", {
	description = "Cooked Mammal Meat",
	inventory_image = "paleotest_meat_cooked.png",
	groups = {eatable = 1, meat = 1, cooked = 1},
	on_use = minetest.item_eat(8)
})

-- Fish Meat --

minetest.register_craftitem("paleotest:fish_meat_raw", {
	description = "Raw Fish Meat",
	inventory_image = "paleotest_fish_meat_raw.png",
	groups = {eatable = 1, meat = 1, raw = 1},
	on_use = minetest.item_eat(2)
})

minetest.register_craftitem("paleotest:fish_meat_cooked", {
	description = "Cooked Fish Meat",
	inventory_image = "paleotest_meat_cooked.png",
	groups = {eatable = 1, meat = 1, cooked = 1},
	on_use = minetest.item_eat(8)
})

-----------------------
-- Fossils and Bones --
-----------------------

minetest.register_craftitem("paleotest:fossil", { -- Fossil
	description = "Fossil",
	inventory_image = "paleotest_fossil.png",
	groups = {fossil = 1},
})

minetest.register_craftitem("paleotest:plant_fossil", { -- Plant Fossil
	description = "Plant Fossil",
	inventory_image = "paleotest_plant_fossil.png",
	groups = {fossil = 1},
})

minetest.register_craftitem("paleotest:ancient_bones", { -- Ancient Bones
	description = "Ancient Bones",
	inventory_image = "paleotest_ancient_bones.png",
	groups = {fossil = 1},
})

minetest.register_craftitem("paleotest:fossilized_cycad_seeds", { -- Fossil
	description = "Fossilized Cycad Seeds",
	inventory_image = "paleotest_fossilized_cycad_seeds.png",
	groups = {fossil = 1},
})

minetest.register_craftitem("paleotest:fossilized_horsetail_spores", { -- Fossil
	description = "Fossilized Horsetail Spores",
	inventory_image = "paleotest_fossilized_horsetail_spores.png",
	groups = {fossil = 1},
})

minetest.register_craftitem("paleotest:metasequoia_sapling_petrified", { -- Fossil
	description = "Petrified Metasequoia Sapling",
	inventory_image = "paleotest_metasequoia_sapling_petrified.png",
	groups = {fossil = 1},
})


---------
-- DNA --
---------

minetest.register_craftitem("paleotest:dna_brachiosaurus", { -- Brachiosaurus DNA
	description = "Brachiosaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_carnotaurus", { -- Carnotaurus DNA
	description = "Carnotaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_dire_wolf", { -- Dire Wolf DNA
	description = "Dire Wolf DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_dunkleosteus", { -- Dunkleosteus DNA
	description = "Dunkleosteus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_elasmotherium", { -- Elasmotherium DNA
	description = "Elasmotherium DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_mammoth", { -- Mammoth DNA
	description = "Mammoth DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_mosasaurus", { -- Mosasaurus DNA
	description = "Mosasaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_procoptodon", { -- Procoptodon DNA
	description = "Procoptodon DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_plesiosaurus", { -- Plesiosaurus DNA
	description = "Plesiosaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_pteranodon", { -- Pteranodon DNA
	description = "Pteranodon DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_quetzalcoatlus", { -- Quetzalcoatlus DNA
	description = "Quetzalcoatlus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_sarcosuchus", { -- Sarcosuchus DNA
	description = "Sarcosuchus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_smilodon", { -- Smilodon DNA
	description = "Smilodon DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_spinosaurus", { -- Spinosaurus DNA
	description = "Spinosaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_stegosaurus", { -- Stegosaurus DNA
	description = "Stegosaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_thylacoleo", { -- Thylacoleo DNA
	description = "Thylacoleo DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_triceratops", { -- Triceratops DNA
	description = "Triceratops DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_tyrannosaurus", { -- Tyrannosaurus DNA
	description = "Tyrannosaurus DNA",
	inventory_image = "paleotest_dna.png",
})

minetest.register_craftitem("paleotest:dna_velociraptor", { -- Velociraptor DNA
	description = "Velociraptor DNA",
	inventory_image = "paleotest_dna.png",
})

----------
-- Eggs --
----------

paleotest.register_egg("paleotest:brachiosaurus", 1.25, true)

paleotest.register_egg("paleotest:carnotaurus", 0.75, true)

paleotest.register_egg("paleotest:pteranodon", 0.25, true)

paleotest.register_egg("paleotest:quetzalcoatlus", 0.75, true)

paleotest.register_egg("paleotest:sarcosuchus", 0.75, false)

paleotest.register_egg("paleotest:spinosaurus", 1, false)

paleotest.register_egg("paleotest:stegosaurus", 0.75, true)

paleotest.register_egg("paleotest:triceratops", 1, true)

paleotest.register_egg("paleotest:tyrannosaurus", 1, false)

paleotest.register_egg("paleotest:velociraptor", 0.5, true)

--------------
-- Syringes --
--------------

paleotest.register_syringe("paleotest:dire_wolf",true)

paleotest.register_syringe("paleotest:elasmotherium",true)

paleotest.register_syringe("paleotest:mammoth",true)

paleotest.register_syringe("paleotest:procoptodon",true)

paleotest.register_syringe("paleotest:smilodon",true)

paleotest.register_syringe("paleotest:thylacoleo",true)

--------------------
-- Embryonic Sacs --
--------------------

paleotest.register_embryo_sac("paleotest:dunkleosteus",false)

paleotest.register_embryo_sac("paleotest:mosasaurus",false)

paleotest.register_embryo_sac("paleotest:plesiosaurus",true)

------------------
-- Pursuit Ball --
------------------

local abs = math.abs
local min = math.min

local function ball_physics(self)
	local vel = self.object:get_velocity()
	if self.lastvelocity.y==0 and vel.y==0 then
		self.isonground = true
	else
		self.isonground = false
	end
	if self.isonground and not self.isinliquid then
		self.object:set_velocity({x= vel.x> 0.2 and vel.x*0.7 or 0,
								y=vel.y,
								z=vel.z > 0.2 and vel.z*0.7 or 0})
	end
	-- buoyancy
	local surface = nil
	local surfnodename = nil
	local spos = mobkit.get_stand_pos(self)
	spos.y = spos.y+0.01
	-- get surface height
	local snodepos = mobkit.get_node_pos(spos)
	local surfnode = mobkit.nodeatpos(spos)
	while surfnode and surfnode.drawtype == 'liquid' do
		surfnodename = surfnode.name
		surface = snodepos.y+0.5
		if surface > spos.y + 0.75 then break end
		snodepos.y = snodepos.y+1
		surfnode = mobkit.nodeatpos(snodepos)
	end
	self.isinliquid = surfnodename
	if surface then
		local submergence = min(surface-spos.y, 0.75)/0.75
		local buoyacc = -9.8*(0.5-submergence)
		mobkit.set_acceleration(self.object,
			{x=-vel.x,y=buoyacc-vel.y*abs(vel.y)*0.4,z=-vel.z})
	else
		self.object:set_acceleration({x=0,y=-9.8,z=0})
	end
	local pos = self.object:get_pos()
	local hitbox = self.object:get_properties().collisionbox
	local width = -hitbox[1] + hitbox[4] + 0.5
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, width)) do
		if (object and object ~= self.object)
		and (object:is_player() or (object:get_luaentity() and object:get_luaentity().logic))
		and (not object:get_attach() or (object:get_attach() and object:get_attach() ~= self.object))
		and (not self.object:get_attach() or (self.object:get_attach() and self.object:get_attach() ~= object)) then
			local pos2 = object:get_pos()
			local dir = vector.direction(pos,pos2)
			dir.y = 0
			if dir.x == 0 and dir.z == 0 then
				dir = vector.new(math.random(-1,1)*math.random(),0,math.random(-1,1)*math.random())
			end
			local velocity = vector.multiply(dir,1.1)
			local vel1 = vector.multiply(velocity, -1)
			local vel2 = velocity
			self.object:add_velocity(vel1)
			if object:is_player() then
				object:add_player_velocity(vel2)
			else
				object:add_velocity(vel2)
			end
		end
	end
end

local ball_def = {
    max_hp = 10,
    armor_groups = {immortal = 1},
    max_speed = 0,
    stepheight = 0,
    jump_height = 0,
    buoyancy = 0.5,
    springiness = 0,
    collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.375, 0.375},
    visual_size = {x = 15, y = 15},
    visual = "mesh",
	mesh = "paleotest_pursuit_ball.b3d",
	textures = {"paleotest_pursuit_ball.png"},
    physical = true,
	collide_with_objects = true,
    static_save = true,
	timeout = 0,
	on_activate = function(self)
		self.object:set_armor_groups({immortal = 1})
		self.lastvelocity = {x=0,y=0,z=0}
	end,
    on_step = function(self)
        ball_physics(self)
        local pos = self.object:get_pos()
        local _,rot = self.object:get_bone_position("Bone")
        for _,object in ipairs(minetest.get_objects_inside_radius(pos, 0.75)) do
            if object ~= self.object then
                rot.x = rot.x - 10
                local pos2 = object:get_pos()
                local dir = vector.direction(pos,pos2)
                local yaw = minetest.dir_to_yaw(dir)
                local tyaw = minetest.dir_to_yaw(self.object:get_velocity())
                if math.abs(tyaw-yaw) > 0.1 then
					self.object:set_yaw(tyaw)
                end
            end
        end
        local vel = self.object:get_velocity()
        if vector.length(vel) ~= 0 and not self.isinliquid then
            rot.x = rot.x - 10
        end
        self.object:set_bone_position("Bone",{x=0,y=0,z=0},{x=rot.x,y=0,z=0})
    end,
    on_punch = function(self, puncher)
        local dir = vector.direction(puncher:get_pos(),self.object:get_pos())
        local hvel = vector.multiply(vector.normalize({x=dir.x,y=0,z=dir.z}),4)
		self.object:set_velocity({x=hvel.x,y=2,z=hvel.z})
		local tyaw = minetest.dir_to_yaw(dir)
        self.object:set_yaw(tyaw)
    end,
    on_rightclick = function(self,clicker)
        if clicker:get_player_control().sneak == true then
            return
        end
        local inv = clicker:get_inventory()
        if inv:room_for_item("main", {name = "paleotest:pursuit_ball"}) then
            clicker:get_inventory():add_item("main", "paleotest:pursuit_ball")
        else
            local pos = self.object:get_pos()
            pos.y = pos.y + 0.5
            minetest.add_item(pos, {name = "paleotest:pursuit_ball"})
        end
        self.object:remove()
    end
}

minetest.register_entity("paleotest:pursuit_ball_ent", ball_def)

minetest.register_craftitem("paleotest:pursuit_ball", {
    description = "Pursuit Ball",
    inventory_image = "paleotest_pursuit_ball_inv.png",
	on_place = function(itemstack, _, pointed_thing)
        local pos = minetest.get_pointed_thing_position(pointed_thing, true)
        pos.y = pos.y + 0.5
        minetest.add_entity(pos, "paleotest:pursuit_ball_ent")
        if not creative then
            itemstack:take_item()
            return itemstack
        end
    end,
})