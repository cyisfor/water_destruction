-- stolen from builtin/game/falling.lua which made it a local function too.
local function drop(p)
        local nn = core.get_node(p).name
        for _, item in pairs(core.get_node_drops(nn, "")) do
                local pos = {
                        x = p.x + math.random()/2 - 0.25,
                        y = p.y + math.random()/2 - 0.25,
                        z = p.z + math.random()/2 - 0.25,
                }
                core.add_item(pos, item)
        end
end

local function enfloodify(name,def)
	 def = table.copy(def) -- because minetest devs hate fun
	 
	 def.floodable = true
	 def.on_flood = drop 
	 core.register_node(":" .. name, def)
end

local function fixname(name)
	 return "water_destruction:" .. name:gsub(":","_")
end
	 
local function code_duplication(def)
	 local ceiling = fixname("default:torch_ceiling")
	 local torch = fixname("default:torch")
	 local wall = fixname("default:torch_wall")
	 
	 def.on_place = function(itemstack, placer, pointed_thing)
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local def = minetest.registered_nodes[node.name]
			if def and def.on_rightclick and
			((not placer) or (placer and not placer:get_player_control().sneak)) then
				 return def.on_rightclick(under, node, placer, itemstack,
																	pointed_thing) or itemstack
			end

			local above = pointed_thing.above
			local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))
			local fakestack = itemstack
			if wdir == 0 then
				 fakestack:set_name(ceiling)
			elseif wdir == 1 then
				 fakestack:set_name(torch)
			else
				 fakestack:set_name(wall)
			end

			itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name("default:torch")

			return itemstack
	 end
end

local function l8r()
	 for name,def in pairs(core.registered_nodes) do
			if def.groups.flora or def.groups.plant or def.groups.torch then
				 enfloodify(name,table.copy(def))
			end
			if def.groups.torch then
				 -- sneak in the waterproof torch yes
				 def = table.copy(def)
				 local function bluify(name)
						local v = def[name]
						if v == nil then return end
						def[name] = v .. "^[multiply:#00FF88:255"
				 end
				 bluify("inventory_image")
				 bluify("wield_image")
				 if def.tiles ~= nil then
						for i,tile in ipairs(def.tiles) do
							 tile.name = tile.name .. "^[multiply:#00FF88:255"
						end
						print(def.tiles[1].name)
				 end
				 -- sigh...
				 if def.on_place then
						code_duplication(def)
				 end
				 if def.description ~= nil then
						def.description = "Waterproof " .. def.description
				 end
				 def.name = nil
				 local fname = fixname(name)
				 def.drop = fixname(def.drop)
				 -- have to prefix our own module in :
				 -- because minetest errors out for no reason if you use the "wrong" modname prefix
				 -- since that broke everything ever and made life terrible, devs were forced
				 -- to allow mods to communicate with each other. but in the name of teh security
				 -- they decided to do the pointless verification anyway, unless you prefix
				 -- with a colon. since this code must run after core.registered_nodes is populated,
				 -- it cannot have a "current" modname, so check_modname_prefix stupidly ends up
				 -- concatenating nil, when check_modname_prefix doesn't even need to exist.
				 core.register_node(":" .. fname, def)
				 core.register_craft({
							 output = fname,
							 type = 'shapeless',
							 recipe = {
									name,
									"default:grass_1"
							 }
				 })
												 
			end
	 end
end

core.after(0,l8r)
