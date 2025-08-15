local module = {}

local SEPARATION_DISTANCE = 5
local SEPARATION_FORCE = 10
function module.getSeparationForce(npc) 
	local root = npc.PrimaryPart
	if not root then return Vector3.zero end

	local force = Vector3.zero
	local count = 0

	for _, other in ipairs(_G.NPCs) do
		if other.NPC ~= npc and other.NPC.PrimaryPart then
			local distance = (root.Position - other.NPC.PrimaryPart.Position).Magnitude
			if distance < SEPARATION_DISTANCE and distance > 0 then
				local awayVector = (root.Position - other.NPC.PrimaryPart.Position).unit / distance
				force += awayVector
				count += 1
			end
		end
	end

	if count > 0 then
		force = (force / count) * SEPARATION_FORCE
	end

	return force
end

return module
