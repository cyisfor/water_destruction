-- stolen from builtin/game/falling.lua which made it a local function too.
local function drop(p)
        local nn = core.get_node(p).name
        core.remove_node(p)
        for _, item in pairs(core.get_node_drops(nn, "")) do
                local pos = {
                        x = p.x + math.random()/2 - 0.25,
                        y = p.y + math.random()/2 - 0.25,
                        z = p.z + math.random()/2 - 0.25,
                }
                core.add_item(pos, item)
        end
end

local neighbors = {"group:plant","group:flora","group:torch"}
core.register_abm({
			label = "Destroy things",
			nodenames = {"group:water"},
			neighbors = neighbors,
			catch_up = false,
			interval = 3,
			chance = 1,
			action = function(pos, node, count, count_wider)
				 local minp = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
				 local maxp = {x=pos.x+1,y=pos.y+1,z=pos.z+1}
				 local ns = core.find_nodes_in_area(minp,maxp,neighbors)
				 for _,pos in ipairs(ns) do
						drop(pos)
				 end
			end						
})
