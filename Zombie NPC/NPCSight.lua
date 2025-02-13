local module = {}

local function hasClearLineOfSight(npc, target)
	local origin = npc.PrimaryPart.Position
	local destination = target.PrimaryPart.Position
	local direction = (destination - origin).unit * (destination - origin).magnitude

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {game.Workspace.Alive["NPC's"]} 
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, rayParams)
	return result == nil or (result.Instance and result.Instance:IsDescendantOf(target))
end

local function isInFieldOfView(npc, target, fovAngle)
	local npcPosition = npc.PrimaryPart.Position
	local targetPosition = target.PrimaryPart.Position

	local directionToTarget = (targetPosition - npcPosition).unit
	local npcLookDirection = npc.PrimaryPart.CFrame.LookVector

	local dotProduct = npcLookDirection:Dot(directionToTarget)
	local angle = math.deg(math.acos(dotProduct))

	return angle <= fovAngle / 2
end

function module.CheckSight(npc, target, fovAngle)
	if not npc or not target or not npc.PrimaryPart or not target.PrimaryPart then
		return false 
	end

	local player = game.Players:GetPlayerFromCharacter(target)
	if not player then
		return false 
	end

	if not isInFieldOfView(npc, target, fovAngle) then
		return false 
	end

	if not hasClearLineOfSight(npc, target) then
		return false 
	end

	return true 
end

return module
