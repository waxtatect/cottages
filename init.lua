-- Version: 2.2
-- Autor:   Sokomine
-- License: GPLv3
--
-- Modified:
-- 11.03.19 Adjustments for MT 5.x
--          cottages_feldweg_mode is now a setting in minetest.conf
-- 27.07.15 Moved into its own repository.
--          Made sure textures and craft receipe indigrents are available or can be replaced.
--          Took care of "unregistered globals" warnings.
-- 23.01.14 Added conversion receipes in case of installed castle-mod (has its own anvil)
-- 23.01.14 Added hammer and anvil as decoration and for repairing tools.
--          Added hatches (wood and steel).
--          Changed the texture of the fence/handrail.
-- 17.01.13 Added alternate receipe for fences in case of interference due to xfences
-- 14.01.13 Added alternate receipes for roof parts in case homedecor is not installed.
--          Added receipe for stove pipe, tub and barrel.
--          Added stairs/slabs for dirt road, loam and clay
--          Added fence_small, fence_corner and fence_end, which are useful as handrails and fences
--          If two or more window shutters are placed above each other, they will now all close/open simultaneously.
--          Added threshing floor.
--          Added hand-driven mill.

cottages = {}
cottages.S = minetest.get_translator("cottages")

cottages.sounds = {}
-- MineClone2 needs special treatment, default is only needed for
-- crafting materials and sounds (less important)
if(not(minetest.get_modpath("default"))) then
	default = {}
	cottages.sounds.wood   = nil
	cottages.sounds.dirt   = nil
	cottages.sounds.leaves = nil
	cottages.sounds.stone  = nil
else
	cottages.sounds.wood   = default.node_sound_wood_defaults()
	cottages.sounds.dirt   = default.node_sound_dirt_defaults()
	cottages.sounds.stone  = default.node_sound_stone_defaults()
	cottages.sounds.leaves = default.node_sound_leaves_defaults()
end

-- the straw from default comes with stairs as well and might replace
-- cottages:roof_connector_straw and cottages:roof_flat_straw
-- however, that does not look very good
if(false and minetest.registered_nodes["farming:straw"]) then
	cottages.straw_texture = "farming_straw.png"
	cottages.use_farming_straw_stairs = true
else
	cottages.straw_texture = "cottages_darkage_straw.png"
end

cottages.use_farming_redo = minetest.global_exists("farming") and farming.mod == "redo"

-- set alternate crafting materials and textures where needed
-- (i.e. in combination with realtest)
dofile(minetest.get_modpath("cottages").."/adaptions.lua")

dofile(minetest.get_modpath("cottages").."/functions.lua")

local function add_product(name, product, def)
	local desc = cottages.get_def_field(def.type, name, "description")
	cottages[def.product].product[name] = product
	cottages[def.product].description[name] = desc
	if def.sp == "threshing_redo" then desc = cottages.get_def_field("craftitem", name:gsub("seed_", ""), "description") end
	cottages[def.product].desc[#cottages[def.product].desc + 1] = desc
end

-- add to this table what you want the threshing floor to convert
-- add a stack size if you want a higher yield
cottages.threshing = {
	product = {[cottages.craftitem_grain_wheat] = cottages.craftitem_seed_wheat},
	description = {[cottages.craftitem_grain_wheat] = cottages.get_def_field("craftitem", cottages.craftitem_grain_wheat, "description")},
	desc = {cottages.get_def_field("craftitem", cottages.craftitem_grain_wheat, "description")}
}

if cottages.use_farming_redo then
	local def = {product = "threshing", type = "craftitem"}
	add_product(cottages.craftitem_grain_barley, cottages.craftitem_seed_barley, def)
	add_product(cottages.craftitem_grain_oat, cottages.craftitem_seed_oat, def)
	add_product(cottages.craftitem_grain_rice, cottages.craftitem_seed_rice, def)
	add_product(cottages.craftitem_grain_rye, cottages.craftitem_seed_rye, def)
end

-- add to this table what you want the handmill to convert
-- add a stack size if you want a higher yield
cottages.handmill = {
	product = {[cottages.craftitem_seed_wheat] = "farming:flour 1"},
	description = {[cottages.craftitem_seed_wheat] = cottages.get_def_field("craftitem", cottages.craftitem_grain_wheat, "description")},
	desc = {cottages.get_def_field("craftitem", cottages.craftitem_grain_wheat, "description")}
}

if cottages.use_farming_redo then
	local def = {product = "handmill", sp = "threshing_redo"}
	add_product(cottages.craftitem_seed_barley, "farming:flour 1", def)
	add_product(cottages.craftitem_seed_oat, "farming:flour 1", def)
	add_product(cottages.craftitem_seed_rice, "farming:rice_flour 1", def)
	add_product(cottages.craftitem_seed_rye, "farming:flour 1", def)
end

--[[some examples:
add_product("default:cobble", "default:gravel", {product = "handmill"})
add_product("default:gravel", "default:sand", {product = "handmill"})
add_product("default:sand", "default:dirt 2", {product = "handmill"})
add_product("flowers:rose", "dye:red 6", {product = "handmill"})
add_product("default:cactus", "dye:green 6", {product = "handmill"})
add_product("default:coal_lump", "dye:black 6", {product = "handmill", type = "craftitem"})
--]]
-- process that many inputs per turn
cottages.handmill_max_per_turn = 20
cottages.handmill_min_per_turn = 0

-- comment parts you do not want
dofile(minetest.get_modpath("cottages").."/nodes_furniture.lua")
dofile(minetest.get_modpath("cottages").."/nodes_historic.lua")
dofile(minetest.get_modpath("cottages").."/nodes_feldweg.lua")
-- allows to dig hay and straw fast
dofile(minetest.get_modpath("cottages").."/nodes_pitchfork.lua")
dofile(minetest.get_modpath("cottages").."/nodes_straw.lua")
dofile(minetest.get_modpath("cottages").."/nodes_hay.lua")
dofile(minetest.get_modpath("cottages").."/nodes_anvil.lua")
dofile(minetest.get_modpath("cottages").."/nodes_doorlike.lua")
dofile(minetest.get_modpath("cottages").."/nodes_fences.lua")
dofile(minetest.get_modpath("cottages").."/nodes_roof.lua")
dofile(minetest.get_modpath("cottages").."/nodes_barrel.lua")
--dofile(minetest.get_modpath("cottages").."/nodes_mining.lua")
dofile(minetest.get_modpath("cottages").."/nodes_water.lua")
--dofile(minetest.get_modpath("cottages").."/nodes_chests.lua")

-- this is only required and useful if you run versions of the random_buildings mod where the nodes where defined inside that mod
dofile(minetest.get_modpath("cottages").."/alias.lua")

-- variable no longer needed
cottages.S = nil