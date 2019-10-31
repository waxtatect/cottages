---------------------------------------------------------------------------------------
-- straw - a very basic material
---------------------------------------------------------------------------------------
--  * straw mat - for animals and very poor NPC, also basis for other straw things
--  * straw bale - well, just a good source for building and decoration

local S = cottages.S

-- an even simpler from of bed - usually for animals 
-- it is a nodebox and not wallmounted because that makes it easier to replace beds with straw mats
minetest.register_node("cottages:straw_mat", {
        description = S("layer of straw"),
	drawtype = 'nodebox',
	tiles = {cottages.straw_texture}, -- done by VanessaE
	wield_image = cottages.straw_texture,
	inventory_image = cottages.straw_texture,
	sunlight_propagates = true,
	paramtype = 'light',
	paramtype2 = "facedir",
	walkable = false,
	groups = {hay = 3, snappy = 2, oddly_breakable_by_hand = 2, flammable= 3},
	sounds = cottages.sounds.leaves,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.48, -0.5,-0.48, 0.48, -0.45, 0.48}}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.48, -0.5,-0.48, 0.48, -0.25, 0.48}}
	},
	is_ground_content = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		return cottages.sleep_in_bed(pos, node, clicker, itemstack, pointed_thing)
	end
})

-- straw bales are a must for farming environments, if you for some reason do not have the darkage mod installed, this here gets you a straw bale
minetest.register_node("cottages:straw_bale", {
	drawtype = "nodebox",
	description = S("straw bale"),
	tiles = {"cottages_darkage_straw_bale.png"},
	paramtype = "light",
	groups = {hay = 3, snappy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = cottages.sounds.leaves,
	-- the bale is slightly smaller than a full node
	node_box = {
		type = "fixed",
		fixed = {
			{-0.45, -0.5,-0.45,  0.45,  0.45, 0.45}}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.45, -0.5,-0.45,  0.45,  0.45, 0.45}}
	},
	is_ground_content = false,
})

-- just straw
if(not(minetest.registered_nodes["farming:straw"])) then
   minetest.register_node("cottages:straw", {
	drawtype = "normal",
	description = S("straw"),
	tiles = {cottages.straw_texture},
	groups = {hay = 3, snappy = 2, oddly_breakable_by_hand = 2, flammable = 3},
	sounds = cottages.sounds.leaves,
	-- the bale is slightly smaller than a full node
	is_ground_content = false
  })
else
	minetest.register_alias("cottages:straw", "farming:straw")
end

local function get_itemdef_field(nodename, fieldname)
	if not minetest.registered_craftitems[nodename] then
		return nil
	end
	return minetest.registered_craftitems[nodename][fieldname]
end
local function get_nodedef_field(nodename, fieldname)
	if not minetest.registered_nodes[nodename] then
		return nil
	end
	return minetest.registered_nodes[nodename][fieldname]
end
local farming_description = {grain = {[cottages.craftitem_grain_wheat] = get_itemdef_field(cottages.craftitem_grain_wheat, "description")}, seed = {}}
farming_description.seed[cottages.craftitem_seed_wheat] = get_nodedef_field(cottages.craftitem_seed_wheat, "description")

if cottages.use_farming_redo then
	farming_description.grain[cottages.craftitem_grain_barley] = get_itemdef_field(cottages.craftitem_grain_barley, "description")
	farming_description.grain[cottages.craftitem_grain_oat] = get_itemdef_field(cottages.craftitem_grain_oat, "description")
	farming_description.grain[cottages.craftitem_grain_rice] = get_itemdef_field(cottages.craftitem_grain_rice, "description")
	farming_description.grain[cottages.craftitem_grain_rye] = get_itemdef_field(cottages.craftitem_grain_rye, "description")

	farming_description.seed[cottages.craftitem_seed_barley] = get_nodedef_field(cottages.craftitem_seed_barley, "description")
	farming_description.seed[cottages.craftitem_seed_oat] = get_nodedef_field(cottages.craftitem_seed_oat, "description")
	farming_description.seed[cottages.craftitem_seed_rice] = get_nodedef_field(cottages.craftitem_seed_rice, "description")
	farming_description.seed[cottages.craftitem_seed_rye] = get_nodedef_field(cottages.craftitem_seed_rye, "description")	
end

local grain_string = ""
local grain_list, i = {}, 1
if cottages.use_farming_redo then
	for _, description in pairs(farming_description.grain) do
		grain_list[i], i = description, i + 1
	end
	grain_string = table.concat(grain_list, ", ")
	grain_string = grain_string:sub(1, #grain_string - 2)
else 
	grain_string = farming_description.grain[cottages.craftitem_grain_wheat]
end
local supported_grain = S("Supported grain :\n @1", grain_string)
local supported_seed = S("Supported seed :\n @1", grain_string)

local cottages_formspec_treshing_floor =
	"size[8,8.5]"..
	"image[3.5,2.5;1,1;"..cottages.texture_stick.."]"..
	"button_exit[3.5,0;1.5,0.5;public;"..S("Public?").."]"..
	"list[context;harvest;1,1;2,1;]"..
	"list[context;straw;6,0;2,2;]"..
	"list[context;seeds;6,2;2,2;]"..
	"label[1,0.5;"..S("Harvested grain:").."]"..
	"label[5,0;"..S("Straw:").."]"..
	"label[5,2;"..S("Seeds:").."]"..
	"label[0,0;"..S("Threshing floor").."]"..
	"label[0,2.5;"..S("Punch threshing floor with a stick").."]"..
	"label[0,2.9;"..S("to get straw and seeds from grain.").."]"..
	"image_button[0,3.4;0.5,0.5;;grain;?]"..
	"tooltip[grain;"..supported_grain.."]"..
	"list[current_player;main;0,4.35;8,1;]"..
	"list[current_player;main;0,5.58;8,3;8]"..
	"listring[current_player;main]"..
	"listring[context;harvest]"..
	"listring[current_player;main]"..
	"listring[context;straw]"..
	"listring[current_player;main]"..
	"listring[context;seeds]"..
	default.get_hotbar_bg(0,4.35)

minetest.register_node("cottages:threshing_floor", {
	drawtype = "nodebox",
	description = S("threshing floor"),
	-- TODO: stone also looks pretty well for this
	tiles = {"cottages_junglewood.png^"..cottages.texture_treshing_floor,"cottages_junglewood.png","cottages_junglewood.png^"..cottages.texture_stick},
	paramtype = "light",
	paramtype2 = "facedir",
	-- can be dug with an axe and a pick
	groups = {cracky = 2, choppy = 2},
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.50, -0.5,-0.50, 0.50, -0.40, 0.50},
			{-0.50, -0.4,-0.50,-0.45, -0.20, 0.50},
			{0.45, -0.4,-0.50, 0.50, -0.20, 0.50},
			{-0.45, -0.4,-0.50, 0.45, -0.20,-0.45},
			{-0.45, -0.4, 0.45, 0.45, -0.20, 0.50}}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.50, -0.5,-0.50, 0.50, -0.20, 0.50}}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Public threshing floor"))
		local inv = meta:get_inventory()
		inv:set_size("harvest", 2)
		inv:set_size("straw", 4)
		inv:set_size("seeds", 4)
		meta:set_string("formspec", cottages_formspec_treshing_floor)
		meta:set_string("public", "public")
	end,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", S("Private threshing floor (owned by @1)", meta:get_string("owner") or ""))
		meta:set_string("formspec",
		cottages_formspec_treshing_floor..
		"image[0,1;1,1;"..cottages.texture_treshing_floor.."]"..
		"label[1.58,0;"..S("Owner: @1", meta:get_string("owner") or "").."]")
		meta:set_string("public", "private")
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		cottages.switch_public(pos, formname, fields, sender, 'threshing floor')
	end,

	can_dig = function(pos,player)
		local meta  = minetest.get_meta(pos)
		local inv   = meta:get_inventory()
		local owner = meta:get_string('owner')

		if(not(inv:is_empty("harvest"))
		  or not(inv:is_empty("straw"))
		  or not(inv:is_empty("seeds"))
		  or not(player)
		  or (owner and owner ~= '' and player:get_player_name() ~= owner)) then
		   return false
		end
		return true
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if(not(cottages.player_can_use(meta, player))) then
			return 0
		end
		return count
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		-- only accept input the threshing floor can use/process
		if(listname=='straw'
		    or listname=='seeds' 
		    or (listname=='harvest' and stack and not(cottages.threshing_product[stack:get_name()]))) then
			return 0
		end

		if(not(cottages.player_can_use(meta, player))) then
			return 0
		end
		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if(not(cottages.player_can_use(meta, player))) then
                        return 0
		end
		return stack:get_count()
	end,

	on_punch = function(pos, node, puncher)	
		if(not(pos) or not(node) or not(puncher)) then
			return
		end
		-- only punching with a normal stick is supposed to work
		local wielded = puncher:get_wielded_item()
		if(not(wielded)
		    or not(wielded:get_name())
		    or not(minetest.registered_items[wielded:get_name()])
		    or not(minetest.registered_items[wielded:get_name()].groups)
		    or not(minetest.registered_items[wielded:get_name()].groups.stick)) then
 			return
		end
		local name = puncher:get_player_name()

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local input = inv:get_list('harvest')
		-- we have two input slots
		local stack1 = inv:get_stack('harvest', 1)
		local stack2 = inv:get_stack('harvest', 2)

		if((stack1:is_empty() and stack2:is_empty())
			or(not(stack1:is_empty()) and not(cottages.threshing_product[stack1:get_name()]))
			or(not(stack2:is_empty()) and not(cottages.threshing_product[stack2:get_name()]))) then

			-- minetest.chat_send_player(name, 'One of the input slots contains something else than grain, or there is no grain at all.')
			-- update the formspec
			meta:set_string("formspec",
				cottages_formspec_treshing_floor..
				"image[0,1;1,1;"..cottages.current_texture_treshing_floor.."]"..
				"label[1.58,0;"..S("Owner: @1", meta:get_string("owner") or "").."]")
			return
		end

		if not(stack1:is_empty()) and not(stack2:is_empty())
			and stack1:get_name() ~= stack2:get_name() then

			minetest.chat_send_player(name, S("Choose one type of grain: @1 or @2", farming_description.grain[stack1:get_name()], farming_description.grain[stack2:get_name()]))
			-- update the formspec
			meta:set_string("formspec",
				cottages_formspec_treshing_floor..
				"image[0,1;1,1;"..cottages.current_texture_treshing_floor.."]"..
				"label[1.58,0;"..S("Owner: @1", meta:get_string("owner") or "").."]")
			return
		end

		-- on average, process 25 grains at each punch (10..40 are possible)
		local anz = 10 + math.random(0, 30)
		-- we already made sure there is only grain inside
		local found = stack1:get_count() + stack2:get_count()

		-- do not process more grain than present in the input slots
		if(found < anz) then
			anz = found
		end

		local stack = stack1
		if stack:get_count() <= 0 then stack = stack2 end
		local product = stack:get_name():match("^farming:(%l+)") or "wheat"

		local texture_grain = "farming_"..product..".png"
		if cottages.current_texture_treshing_floor ~= texture_grain then
			cottages.current_texture_treshing_floor = texture_grain
			meta:set_string("formspec",
				cottages_formspec_treshing_floor..
				"image[0,1;1,1;"..texture_grain.."]"..
				"label[1.58,0;"..S("Owner: @1", meta:get_string("owner") or "").."]")
		end

		local overlay1 = "^"..texture_grain
		local overlay2 = "^"..cottages.straw_texture
		local overlay3 = "^"..cottages["texture_seed_"..product]

		local product_stack = ItemStack(cottages.threshing_product[stack:get_name()])
		-- this can be enlarged by a multiplicator if desired
		local anz_straw = anz
		local anz_seeds = anz
		if(product_stack:get_count() > 1) then
			anz_seeds = anz * product_stack:get_count()
		end

		if(inv:room_for_item('straw','cottages:straw_mat '..tostring(anz_straw))
		   and inv:room_for_item('seeds', product_stack:get_name()..' '..tostring(anz_seeds))) then

			-- the player gets two kind of output
			inv:add_item("straw", 'cottages:straw_mat '..tostring(anz_straw))
			inv:add_item("seeds", product_stack:get_name()..' '..tostring(anz_seeds))
			-- consume the grain
			inv:remove_item("harvest", stack:get_name()..' '..tostring(anz))

			local anz_left = found - anz
			if(anz_left > 0) then
				-- minetest.chat_send_player(name, S('You have threshed @1 grains (@2 are left).', anz, anz_left))
			else
				-- minetest.chat_send_player(name, S('You have threshed the last @1 grain.', anz))
				overlay1 = ""
			end
		end

		local hud0 = puncher:hud_add({
			hud_elem_type = "image",
			scale = {x = 38, y = 38},
			text = "cottages_junglewood.png^[colorize:#888888:128",
			position = {x = 0.5, y = 0.5},
			alignment = {x = 0, y = 0}
		})

		local hud1 = puncher:hud_add({
			hud_elem_type = "image",
			scale = {x = 15, y = 15},
			text = "cottages_junglewood.png"..overlay1,
			position = {x = 0.4, y = 0.5},
			alignment = {x = 0, y = 0}
		})
		local hud2 = puncher:hud_add({
			hud_elem_type = "image",
			scale = {x = 15, y = 15},
			text = "cottages_junglewood.png"..overlay2,
			position = {x = 0.6, y = 0.35},
			alignment = {x = 0, y = 0}
		})
		local hud3 = puncher:hud_add({
			hud_elem_type = "image",
			scale = {x = 15, y = 15},
			text = "cottages_junglewood.png"..overlay3,
			position = {x = 0.6, y = 0.65},
			alignment = {x = 0, y = 0}
		})

		local hud4 = puncher:hud_add({
			hud_elem_type = "text",
			text = tostring(found - anz),
			number = 0x00CC00,
			alignment = {x = 0, y = 0},
			scale = {x = 100, y = 100}, -- bounding rectangle of the text
			position = {x = 0.4, y = 0.5},
		})
		if(not(anz_straw)) then
			anz_straw = "0"
		end
		if(not(anz_seeds)) then
			anz_seeds = "0"
		end
		local hud5 = puncher:hud_add({
			hud_elem_type = "text",
			text = '+ '..tostring(anz_straw).." "..S("straw"),
			number = 0x00CC00,
			alignment = {x = 0, y = 0},
			scale = {x = 100, y = 100}, -- bounding rectangle of the text
			position = {x = 0.6, y = 0.35},
		})
		local hud6 = puncher:hud_add({
			hud_elem_type = "text",
			text = '+ '..tostring(anz_seeds).." "..S("seeds"),
			number = 0x00CC00,
			alignment = {x = 0, y = 0},
			scale = {x = 100, y = 100}, -- bounding rectangle of the text
			position = {x = 0.6, y = 0.65},
		})

		minetest.after(2, function()
			if(puncher) then
				puncher:hud_remove(hud1)
				puncher:hud_remove(hud2)
				puncher:hud_remove(hud3)
				puncher:hud_remove(hud4)
				puncher:hud_remove(hud5)
				puncher:hud_remove(hud6)
				puncher:hud_remove(hud0)
			end
		end)
	end,
})

local cottages_formspec_handmill =
	"size[8,8.5]"..
	"button_exit[6,0;1.5,0.5;public;"..S("Public?").."]"..
	"list[context;seeds;1,1.2;1,1;]"..
	"list[context;flour;5,1.2;2,2;]"..
	"label[0,0.7;"..S("Seeds:").."]"..
	"label[4,0.7;"..S("Flour:").."]"..
	"label[0,0;"..S("Mill").."]"..
	"label[0,2.7;"..S("Punch this hand-driven mill").."]"..
	"label[0,3.1;"..S("to convert seeds into flour.").."]"..
	"image_button[0,3.6;0.5,0.5;;grain;?]"..
	"tooltip[grain;"..supported_seed.."]"..
	"list[current_player;main;0,4.35;8,1;]"..
	"list[current_player;main;0,5.58;8,3;8]"..
	"listring[context;flour]"..
	"listring[current_player;main]"..
	"listring[context;seeds]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0,4.35)

minetest.register_node("cottages:handmill", {
	description = S("mill, powered by punching"),
	drawtype = "mesh",
	mesh = "cottages_handmill.obj",
	tiles = {"cottages_stone.png"},
	paramtype  = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2},
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.50, -0.5,-0.50, 0.50, 0.25, 0.50}}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.50, -0.5,-0.50, 0.50,  0.25, 0.50}}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Public mill, powered by punching"))
		local inv = meta:get_inventory()
		inv:set_size("seeds", 1)
		inv:set_size("flour", 4)
		meta:set_string("formspec", cottages_formspec_handmill)
		meta:set_string("public", "public")
	end,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", S("Private mill, powered by punching (owned by @1)", meta:get_string("owner") or ""))
		meta:set_string("formspec",
		cottages_formspec_handmill..
		"image[0,1.2;1,1;"..cottages.texture_handmill.."]"..
		"label[2.5,0;"..S("Owner: @1", meta:get_string('owner') or "").."]")
		meta:set_string("public", "private")
        end,

	on_receive_fields = function(pos, formname, fields, sender)
		cottages.switch_public(pos, formname, fields, sender, 'mill, powered by punching')
	end,

	can_dig = function(pos,player)
		local meta  = minetest.get_meta(pos)
		local inv   = meta:get_inventory()
		local owner = meta:get_string('owner')

		if(not(inv:is_empty("flour"))
		  or not(inv:is_empty("seeds"))
		  or not(player)
		  or (owner and owner ~= ''  and player:get_player_name() ~= owner)) then
		   return false
		end
		return true
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if(not(cottages.player_can_use(meta, player))) then
                        return 0
		end
		return count
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		-- only accept input the threshing floor can use/process
		if(listname=='flour'
		    or (listname=='seeds' and stack and not(cottages.handmill_product[stack:get_name()]))) then
			return 0
		end

		if(not(cottages.player_can_use(meta, player))) then
			return 0
		end
		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if(not(cottages.player_can_use(meta, player))) then
			return 0
		end
		return stack:get_count()
	end,

	-- this code is very similar to the threshing floor, except that it has only one input- and output-slot
	-- and does not require the usage of a stick
	on_punch = function(pos, node, puncher)
		if(not(pos) or not(node) or not(puncher)) then
			return
		end
		local name = puncher:get_player_name()

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		local input = inv:get_list('seeds')
		local stack1 = inv:get_stack('seeds', 1)

		if((stack1:is_empty())
			or(not(stack1:is_empty())
			     and not(cottages.handmill_product[stack1:get_name()]))) then

			if not(stack1:is_empty()) then
				minetest.chat_send_player(name,"Nothing happens...")
			end
			-- update the formspec
			meta:set_string("formspec",
				cottages_formspec_handmill..
				"image[0,1.2;1,1;"..cottages.current_texture_handmill.."]"..
				"label[2.5,0;"..S("Owner: @1", meta:get_string('owner') or "").."]")
			return
		end

		-- turning the mill is a slow process 1-21 flour(s) are generated per turn
		local anz = 1 + math.random(cottages.handmill_min_per_turn, cottages.handmill_max_per_turn)
		-- we already made sure there is only supported grain inside
		local found = stack1:get_count()

		-- do not process more grain than present in the input slots
		if(found < anz) then
			anz = found
		end

		local product = stack1:get_name():match("^farming:seed_(%l+)") or "wheat"
		local texture_grain = "farming_"..product.."_seed.png"
		if cottages.current_texture_handmill ~= texture_grain then
			cottages.current_texture_handmill = texture_grain
			meta:set_string("formspec",
				cottages_formspec_handmill..
				"image[0,1.2;1,1;"..texture_grain.."]"..
				"label[2.5,0;"..S("Owner: @1", meta:get_string("owner") or "").."]")
		end

		local product_stack = ItemStack(cottages.handmill_product[stack1:get_name()])
		local anz_result = anz
		-- items that produce more
		if(product_stack:get_count()> 1) then
			anz_result = anz * product_stack:get_count()
		end

		if(inv:room_for_item('flour', product_stack:get_name()..' '..tostring(anz_result))) then
			inv:add_item('flour', product_stack:get_name()..' '..tostring(anz_result))
			inv:remove_item('seeds', stack1:get_name()..' '..tostring(anz))

			local anz_left = found - anz
			if(anz_left > 0) then
				minetest.chat_send_player(name, S('You have ground a @1 (@2 are left).', farming_description.seed[stack1:get_name()], anz_left))
			else
				minetest.chat_send_player(name, S('You have ground the last @1.', farming_description.seed[stack1:get_name()]))
			end

			-- if the version of MT is recent enough, rotate the mill a bit
			if(minetest.swap_node) then
				node.param2 = node.param2 + 1
				if(node.param2 > 3) then
					node.param2 = 0
				end
				minetest.swap_node(pos, node)
			end
		end
	end
})

---------------------------------------------------------------------------------------
-- crafting recipes
---------------------------------------------------------------------------------------
-- this returns corn as well
-- the replacements work only if the replaced slot gets empty...
minetest.register_craft({
	output = "cottages:straw_mat 6",
	recipe = {
		{cottages.craftitem_stone, ""             , ""},
		{"farming:wheat"         , "farming:wheat", "farming:wheat",}
	},
	replacements = {{cottages.craftitem_stone, cottages.craftitem_seed_wheat.." 3"}}
})

-- this is a better way to get straw mats
minetest.register_craft({
	output = "cottages:threshing_floor",
	recipe = {
		{cottages.craftitem_junglewood, cottages.craftitem_chest_locked, cottages.craftitem_junglewood},
		{cottages.craftitem_junglewood, cottages.craftitem_stone       , cottages.craftitem_junglewood}
	}
})

-- and a way to turn grain seeds into flour
minetest.register_craft({
	output = "cottages:handmill",
	recipe = {
		{cottages.craftitem_stick, cottages.craftitem_stone, ""},
		{"", cottages.craftitem_steel                      , ""},
		{"", cottages.craftitem_stone                      , ""}
	}
})

minetest.register_craft({
	output = "cottages:straw_bale",
	recipe = {
		{"cottages:straw_mat"},
		{"cottages:straw_mat"},
		{"cottages:straw_mat"}
	}
})

minetest.register_craft({
	output = "cottages:straw",
	recipe = {
		{"cottages:straw_mat", "cottages:straw_mat", "cottages:straw_mat"}
	}
})

minetest.register_craft({
	output = "cottages:straw",
	recipe = {{"cottages:straw_bale"}}
})

minetest.register_craft({
	output = "cottages:straw_bale",
	recipe = {{"cottages:straw"}}
})

minetest.register_craft({
	output = "cottages:straw_mat 3",
	recipe = {{"cottages:straw_bale"}}
})

-----
-- fuel
-----
minetest.register_craft({
	type = "fuel",
	recipe = "cottages:straw",
	burntime = 3
})

minetest.register_craft({
	type = "fuel",
	recipe = "cottages:straw_bale",
	burntime = 3
})