---------------------------------------------------------------------
-- a barrel and a tub - plus a function that makes 'round' objects
---------------------------------------------------------------------
-- IMPORTANT NOTE: The barrel requires a lot of nodeboxes. That may be
--                 too much for weak hardware!
---------------------------------------------------------------------
-- Functionality: right-click to open/close a barrel
--                punch a barrel to change between vertical/horizontal
---------------------------------------------------------------------
-- Changelog:
-- 24.03.13 Can no longer be opended/closed on rightclick because that is now used for a formspec
--          instead, it can be filled with liquids.
--          Filled barrels will always be closed, while empty barrels will always be open.
-- 15.07.2018 The barrels finally work, and hold 50 buckets of any liquid

-- pipes: table with the following entries for each pipe-part:
--    f: radius factor, if 1, it will have a radius of half a nodebox and fill the entire nodebox
--    h1, h2: height at witch the nodebox shall start and end, usually -0.5 and 0.5 for a full nodebox
--    b: make a horizontal part/shelf
-- horizontal: if 1, then x and y coordinates will be swapped

-- TODO: option so that it works without nodeboxes

local S = cottages.S

barrel = {}

--- 50 bucket barrels
local barrel_max = 50

local liquids = {
	lava = {name = "Lava", bucket = "bucket:bucket_lava"},
	water = {name = "Water", bucket = "bucket:bucket_water"},
	rwater = {name = "River water", bucket = "bucket:bucket_river_water"},
	cactus = {name = "Cactus pulp", bucket = "ethereal:bucket_cactus"},
	milk = {name = "Milk", bucket = "mobs:bucket_milk"},
}

barrel.prepare_formspec = function(fill, contents)
	local label = "nothing"
	local item = "air"
	local hint = ""
	local percent = 0
	if contents then
		hint = liquids[contents].name
		label = contents
		item = liquids[contents].bucket
	end
	if fill then
		percent = 100 * fill / barrel_max
	end

	local formspec =
		"size[8,9]"..
		"image[2.6,2;2,3;default_wood.png^[lowpart:"..
		percent .. ":cottages_water_indicator.png]"..
		"label[2.2,0;"..S("Pour:").."]"..
		"list[context;input;3,0.5;1,1;]"..
		"item_image_button[5,2;1,1;" .. item .. ";" .. label .. ";" .. hint .. "]" ..
		"label[5,3.3;"..S("Fill:").."]"..
		"list[context;output;5,3.8;1,1;]"..
		"list[current_player;main;0,4.85;8,1;]"..
		"list[current_player;main;0,6.08;8,3;8]"..
		"listring[context;output]"..
		"listring[current_player;main]"..
		"listring[context;input]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0,4.85)

	return (formspec)
end

-- prepare formspec
barrel.on_construct = function(pos)
	local meta = minetest.get_meta(pos)

	meta:set_string('liquid_type', '') -- which liquid is in the barrel?
	meta:set_int('liquid_level', 0) -- how much of the liquid is in there?

	local inv = meta:get_inventory()
	inv:set_size("input", 1)  -- to fill in new liquid
	inv:set_size("output", 1)  -- to extract liquid

	meta:set_string('formspec', barrel.prepare_formspec())
	meta:set_string('infotext', S("Empty barrel"))
end

-- can only be dug if there are no more vessels/buckets in any of the slots
-- TODO: allow digging of a filled barrel? this would disallow stacking of them
barrel.can_dig = function(pos, player)
	local  meta = minetest.get_meta(pos)
	local  inv = meta:get_inventory()

	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return false
	end

	return (inv:is_empty('input')
		and inv:is_empty('output')
		and meta:get_int('liquid_level') == 0)
end

-- allow to put into "pour": if barrel is empty OR has the same type AND we know the bucket type AND the barrel is not full
-- allow to put into "fill": if empty bucket and barrel is not empty
barrel.allow_metadata_inventory_put = function(pos, listname, index, stack, player)

	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end

	local iname = stack:get_name()
	local meta = minetest.get_meta(pos)

	if listname == "input" then

		local ltype = nil

		for l,d in pairs(liquids) do
			if d.bucket == iname then
				ltype = l
				break
			end
		end

		if not ltype then
			return 0
		end

		local lt = meta:get_string('liquid_type')
		if lt == "" or (ltype == lt and meta:get_int('liquid_level') < barrel_max) then
			return 1
		else
			return 0
		end
	end

	if listname == "output" then
		if iname == "bucket:bucket_empty" and meta:get_int('liquid_level') > 0 then
			return 1
		else
			return 0
		end
	end

	return 0

end

-- the barrel received input either a new liquid that is to be poured in or a vessel that is to be filled
barrel.on_metadata_inventory_put = function(pos, listname, index, stack, player)

	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local iname = stack:get_name()
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local node = minetest.get_node(pos)

	if listname == "input" then
		local liquid = ""
		for l,d in pairs(liquids) do
			if d.bucket == iname then
				liquid = d.bucket
				inv:set_stack("input", 1, {name = "bucket:bucket_empty"})
				local level = meta:get_int("liquid_level") + 1
				meta:set_int("liquid_level", level)
				meta:set_string("liquid_type", l)

				meta:set_string('formspec', barrel.prepare_formspec(level, l))
				if level == 1 then
					minetest.swap_node(pos, {name = node.name:gsub("_open$",""), param2 = node.param2})
					meta:set_string('infotext', S("Barrel with @1", d.name))
				end
				break
			end
		end
	end

	if listname == "output" then
		local lt = meta:get_string("liquid_type")

		inv:set_stack("output", 1, {name = liquids[lt].bucket})
		local level = meta:get_int("liquid_level") - 1
		if level == 0 then
			minetest.swap_node(pos, {name = node.name .. "_open", param2 = node.param2})
			meta:set_string('infotext', S("Empty barrel"))
			meta:set_string("liquid_type", "")
			meta:set_int("liquid_level", 0)
			lt = nil
		else
			meta:set_int("liquid_level", level)
		end

		meta:set_string('formspec', barrel.prepare_formspec(level, lt))
	end
end

-- Barrels: default = open = empty // closed = has contents

-- this barrel is closed
minetest.register_node("cottages:barrel", {
	description = S("Barrel (closed)"),
	paramtype = "light",
	drawtype = "mesh",
	mesh = "cottages_barrel_closed.obj",
	tiles = {"cottages_barrel.png"},
	groups = {wooden = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, not_in_creative_inventory = 1},
	drop = "cottages:barrel_open",

	on_construct = function(pos)
		return barrel.on_construct(pos)
	end,
	can_dig = function(pos,player)
		return barrel.can_dig(pos, player)
	end,
	allow_metadata_inventory_put = barrel.allow_metadata_inventory_put,
	on_metadata_inventory_put = barrel.on_metadata_inventory_put,

	is_ground_content = false
})

-- this barrel is opened at the top
minetest.register_node("cottages:barrel_open", {
	description = S("Barrel (open)"),
	paramtype = "light",
	drawtype = "mesh",
	mesh = "cottages_barrel.obj",
	tiles = {"cottages_barrel.png"},
	groups = {wooden = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	drop = "cottages:barrel_open",

	on_construct = function(pos)
		return barrel.on_construct(pos)
	end,
	can_dig = function(pos,player)
		return barrel.can_dig(pos, player)
	end,
	allow_metadata_inventory_put = barrel.allow_metadata_inventory_put,
	on_metadata_inventory_put = barrel.on_metadata_inventory_put,

	is_ground_content = false
})

-- horizontal barrel
minetest.register_node("cottages:barrel_lying", {
	description = S("Barrel (closed), lying on its side"),
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "mesh",
	mesh = "cottages_barrel_closed_lying.obj",
	tiles = {"cottages_barrel.png"},
	groups = {wooden = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, not_in_creative_inventory = 1},
	drop = "cottages:barrel_lying_open",
	on_construct = function(pos)
		return barrel.on_construct(pos)
	end,
	can_dig = function(pos,player)
		return barrel.can_dig(pos, player)
	end,
	allow_metadata_inventory_put = barrel.allow_metadata_inventory_put,
	on_metadata_inventory_put = barrel.on_metadata_inventory_put,
	is_ground_content = false
})

-- horizontal barrel, open
minetest.register_node("cottages:barrel_lying_open", {
	description = S("Barrel (opened), lying on its side"),
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "mesh",
	mesh = "cottages_barrel_lying.obj",
	tiles = {"cottages_barrel.png"},
	groups = {wooden = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2,},
	drop = "cottages:barrel_lying_open",
	on_construct = function(pos)
		return barrel.on_construct(pos)
	end,
	can_dig = function(pos,player)
		return barrel.can_dig(pos, player)
	end,
	allow_metadata_inventory_put = barrel.allow_metadata_inventory_put,
	on_metadata_inventory_put = barrel.on_metadata_inventory_put,
	is_ground_content = false
})

-- let's hope "tub" is the correct english word for "bottich"
minetest.register_node("cottages:tub", {
	description = S("Tub"),
	paramtype = "light",
	drawtype = "mesh",
	mesh = "cottages_tub.obj",
	tiles = {"cottages_barrel.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5,-0.1, 0.5},
		}},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5,-0.1, 0.5},
		}},
	groups = {wooden = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
	is_ground_content = false
})

minetest.register_craft({
	output = "cottages:barrel_open",
	recipe = {
		{cottages.craftitem_wood,	"",					cottages.craftitem_wood},
		{cottages.craftitem_steel,	"",					cottages.craftitem_steel},
		{cottages.craftitem_wood,	cottages.craftitem_wood,	cottages.craftitem_wood},
	}
})

minetest.register_craft({
	output = "cottages:barrel_lying_open",
	recipe = {
		{cottages.craftitem_wood,	cottages.craftitem_steel,	cottages.craftitem_wood},
		{cottages.craftitem_wood,	"",          			""},
		{cottages.craftitem_wood,	cottages.craftitem_steel,	cottages.craftitem_wood},
	}
})

minetest.register_craft({
	output = "cottages:tub 2",
	recipe = {
		{"cottages:barrel_open"},
	}
})

minetest.register_craft({
	output = "cottages:barrel_open",
	recipe = {
		{"cottages:tub"},
		{"cottages:tub"},
	}
})