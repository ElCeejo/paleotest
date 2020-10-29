-----------------------
-- Legacy Conversion --
--------- 2.0 ---------

-- Convert Mobs --

minetest.register_globalstep(function()
    local mobs = minetest.luaentities
    for _, mob in pairs(mobs) do
        if mob
        and mob.name:match("^paleotest:")
        and mob._cmi_is_mob then
            if mob.name == "paleotest:elasmosaurus" then
                local pos = mob.object:get_pos()
                minetest.add_entity(pos, "paleotest:plesiosaurus")
                mob.object:remove()
                return
            end
            local pos = mob.object:get_pos()
            mob_core.spawn_child(pos, mob.name)
            mob.object:remove()
        end
    end
end)

-- Convert Items/Nodes --

local old_names = {
    "Brachiosaurus",
    "Cycad",
    "Dilophosaurus",
    "Direwolf",
    "Dunkleosteus",
    "Elasmosaurus",
    "Elasmotherium",
    "Horsetails",
    "Mammoth",
    "Mosasaurus",
    "Procoptodon",
    "Pteranodon",
    "Sarcosuchus",
    "Smilodon",
    "Stegosaurus",
    "Thylacoleo",
    "Triceratops",
    "Tyrannosaurus",
    "Velociraptor",
}

local eggs = {
    "Brachiosaurus",
    "Dilophosaurus",
    "Pteranodon",
    "Sarcosuchus",
    "Spinosaurus",
    "Stegosaurus",
    "Triceratops",
    "Tyrannosaurus",
    "Velociraptor"
}

local syringes = {
    "Elasmotherium",
    "Mammoth",
    "Procoptodon",
    "Smilodon",
    "Thylacoleo"
}

for _, name in pairs(old_names) do
    minetest.register_alias_force("paleotest:desert_"..name.."_fossil_block", "paleotest:fossil_block")
    minetest.register_alias_force("paleotest:"..name.."_fossil_block", "paleotest:fossil_block")
    minetest.register_alias_force("paleotest:"..name.."_fossil", "paleotest:fossil")
    minetest.register_alias_force("paleotest:"..name.."_dna", "paleotest:dna_"..string.lower(name))
end

for _, name in pairs(eggs) do
    minetest.register_alias_force("paleotest:"..name.."_egg", "paleotest:egg_"..string.lower(name))
end

for _, name in pairs(syringes) do
    minetest.register_alias_force("paleotest:"..name.."_baby", "paleotest:syringe_"..string.lower(name))
end

-- New name DNA --

minetest.register_alias_force("paleotest:Direwolf_dna", "paleotest:dna_dire_wolf")
minetest.register_alias_force("paleotest:Elasmosaurus_dna", "paleotest:dna_plesiosaurus")

-- New name birth items --

minetest.register_alias_force("paleotest:Direwolf_baby", "paleotest:syringe_dire_wolf")
minetest.register_alias_force("paleotest:Dunkleosteus_baby", "paleotest:sac_dunkleosteus")
minetest.register_alias_force("paleotest:Elasmosaurus_baby", "paleotest:sac_plesiosaurus")
minetest.register_alias_force("paleotest:Mosasaurus_baby", "paleotest:sac_mosasaurus")

-- Plants --

minetest.register_alias_force("paleotest:Cycad", "paleotest:cycad_3")
minetest.register_alias_force("paleotest:Horsetails", "paleotest:horsetail_3")

-- Fence --

minetest.register_alias_force("paleotest:dinosaur_fence", "paleotest:electric_fence_wires")