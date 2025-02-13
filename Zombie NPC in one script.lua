local Seperation, Attack, NPCSight, Nearest,PathFind, NPCS = {},  {},  {},  {},  {},  {}
local SEPARATION_DISTANCE, SEPARATION_FORCE = 5, 10

-- could not get this script under 269 lines (not including comments) sorry D:
--[[ FUNCTION EXPLANATIONS! 

getSeparationForce(NPCINSTANCE) -- This function helps NPCs avoid overlapping with each other. 
-- Without this, they might end up stacked on top of one another or moving too robotically.
-- It calculates a small force that pushes NPCs apart if they get too close.

NPCS.AddNewNPC(Data) -- Spawns a new NPC from a template and sets up animations and behaviors.
-- It also adds the NPC to the global list so the system can track it. 

NPCS.new(Data) -- Similar to AddNewNPC, but instead of cloning a new NPC, 
-- this function initializes an existing one that was manually placed or loaded.

hasClearLineOfSight(npc, target) -- Uses raycasting to check if the NPC has a direct line of sight to its target.
-- This prevents NPCs from "seeing" through walls or obstacles.

isInFieldOfView(npc, target, fovAngle) -- Checks if the target is within the NPC's vision range.
-- NPCs won't react to things behind them unless they turn around first.

NPCS.CheckSight(npc, target, fovAngle) -- Combines the line-of-sight and field-of-view checks.
-- Basically, it makes sure the NPC can actually see the target before reacting.

NPCS.GetNearestPlayer(NPC) -- Finds the closest player to the NPC.
-- The NPC will prioritize chasing or attacking the nearest player.

NPCS.PathFind(NPC, Target, v) -- Uses the PathfindingService to move the NPC towards its target.
-- If there's an obstacle, it calculates a path around it.
-- It also considers separation force to prevent NPCs from clumping together.

NPCS.NearestBlock(NPC) -- Finds the closest path block, which NPCs might need to destroy to reach their goal.

NPCS.Attack(NPC, target) -- Placeholder for NPC attack logic. This will handle combat behavior.

NPCS.DestroyBlock(NPC, target, i) -- When an NPC encounters a destructible object (like a wooden barrier),
-- it stops moving and starts breaking it down.

visualizeRay(startPos, endPos) -- Creates a temporary red line in the game world to visually represent a raycast.
-- Useful for debugging NPC vision or pathfinding.

--]]
function Seperation.getSeparationForce(npc) 
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
function PathFind.PathFind(NPC, Target, v)
	if not NPC then return end	if not NPC.PrimaryPart then return end if not Target then return end 	if not Target.PrimaryPart then return end
	local path = game.PathfindingService:CreatePath({AgentRadius = 3,		AgentHeight = 6,		AgentCanJump = true,		AgentCanClimb = true,Costs = {}})
	local success, errorMessage = pcall(function() 	path:ComputeAsync(NPC.PrimaryPart.Position, Target.PrimaryPart.Position) end)
	local State = _G.NPCs[v]
	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		if #waypoints >= 2 then
			local movePosition
			local separationForce = Seperation.getSeparationForce(NPC)
			if not waypoints[3] then
				movePosition = waypoints[2] and waypoints[2].Position or waypoints[1].Position
			else
				local Y = waypoints[3].Position - NPC.PrimaryPart.Position
				if Y.y > 1 then
					NPC.Humanoid.Jump = true
				end
				movePosition = waypoints[3].Position
			end
			movePosition = movePosition + separationForce
			NPC.Humanoid:MoveTo(movePosition)
			State.State = "Running"
		else
			State.State = "Idle"
		end
	else
		State.State = "Idle"
	end
end
function Nearest.NearestBlock(NPC)
	local nearestBlock, shortestDistance, npcHRP = nil, math.huge, NPC and NPC:FindFirstChild("HumanoidRootPart")
	if not npcHRP then return nil end
	for _, Block in ipairs(game.Workspace.MAP.PathBlock:GetChildren()) do
		local PrimaryPart = Block.PrimaryPart
		local distance = (PrimaryPart.Position - npcHRP.Position).Magnitude
		if distance < shortestDistance then
			nearestBlock = Block
			shortestDistance = distance
		end
	end
	return nearestBlock
end
function Nearest.GetNearestPlayer(NPC, excludedPlayers)
	local shortestDistance, nearestCharacter, npcHRP = math.huge, nil,  NPC and NPC:FindFirstChild("HumanoidRootPart")
	excludedPlayers = excludedPlayers or {}
	if not npcHRP then return nil end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if not excludedPlayers[player] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local charHRP = player.Character.HumanoidRootPart
			local distance = (charHRP.Position - npcHRP.Position).Magnitude
			if distance < shortestDistance then
				nearestCharacter = player.Character
				shortestDistance = distance
			end
		end
	end
	return nearestCharacter
end
function Attack.Attack(NPC,target, i)
	local  NPCData = _G.NPCs[i]
	local NPC = NPCData.NPC
	local AttackAnimation = NPCData.Animations.AttackAnimation
	if AttackAnimation.IsPlaying then return end
	AttackAnimation:Play()
	local State = _G.NPCs[i]
	State.State = "Attacking"
	AttackAnimation.KeyframeReached:Once(function(KeyFrame)
		if KeyFrame == "Attack" then
			local Hitbox, NPCRoot = Instance.new("Part"), NPC.PrimaryPart or NPC:FindFirstChild("HumanoidRootPart")		Hitbox.Parent = game.Workspace.MAP.Hitboxs		Hitbox.Anchored = true			Hitbox.CanCollide = false			Hitbox.CanQuery = false			Hitbox.CanTouch = false			Hitbox.Transparency = 0.5			Hitbox.Size = Vector3.new(4,5,4)			Hitbox.Color = Color3.new(1, 0, 0)
			Hitbox.CFrame = NPCRoot.CFrame * CFrame.new(0, 0, -3)
			local OverLapParams = OverlapParams.new()
			OverLapParams.FilterType = Enum.RaycastFilterType.Include
			OverLapParams.FilterDescendantsInstances = {game.Workspace.Alive.Players}
			local Humanoids = {}
			if Hitbox then
				local OverlappingParts = workspace:GetPartsInPart(Hitbox, OverLapParams)
				for _, part in pairs(OverlappingParts) do
					local Character = part.Parent
					local Humanoid = Character and Character:FindFirstChild("Humanoid")
					if not table.find(Humanoids, Humanoid) then
						table.insert(Humanoids, Humanoid)
					end
				end
			end
			game:GetService("Debris"):AddItem(Hitbox, 1)
			for i,v  in Humanoids do
				if v then
					v:TakeDamage(20)
				end
			end
			AttackAnimation.Ended:Wait()
		end
		State.State = "Idle"
	end)
end
function Attack.DestroyBlock(NPC, target, i)
	if not NPC or not target then return end
	local Humanoid = NPC:FindFirstChild("Humanoid")
	if not Humanoid then return end
	task.spawn(function()
		local State = _G.NPCs[i]
		State.State = "Attacking" 
		while target and target.Parent do
			local AttackAnim : AnimationTrack = State.Animations.AttackAnimation
			AttackAnim:Play()
			AttackAnim.Ended:Wait()
			if target and target.Parent then
				local TargetHumanoid = target:FindFirstChild("Humanoid")
				if not TargetHumanoid then break end
				TargetHumanoid.Health -= 5
				if target:FindFirstChild("Wood Break") then
					target["Wood Break"]:Play()
				end
				if TargetHumanoid.Health <= 0 then
					target:Destroy()
					break 
				end
			else
				break
			end
		end
		State.State = "Idle"
		NPC:SetAttribute("PathBlocked", nil)
	end)
end
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
function NPCSight.CheckSight(npc, target, fovAngle)
	if not npc or not target or not npc.PrimaryPart or not target.PrimaryPart then		return false 	end
	local player = game.Players:GetPlayerFromCharacter(target)
	if not player then		return false 	end
	if not isInFieldOfView(npc, target, fovAngle) then		return false 	end
	if not hasClearLineOfSight(npc, target) then	return false end
	return true 
end
NPCS.__index = NPCS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local function SetCollisionGroup(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "CollisionPart" then
			part.CollisionGroup = "NPCs"
		end
	end
end
function NPCS.AddNewNPC(Data)
	local self = setmetatable({}, NPCS)
	local NPC = script.Zombie:Clone() NPC.Parent = game.Workspace.Alive["NPC's"]
	local self,Aimator, AnimationsStorage  = setmetatable({}, NPCS),NPC.Humanoid.Animator, game.ServerStorage.Animations.Zombies.Slow
	SetCollisionGroup(NPC)
	local Aimator = NPC.Humanoid.Animator
	local AnimationsStorage = game.ServerStorage.Animations.Zombies.Slow
	local AnimationsTable = {		WalkAnimation = Aimator:LoadAnimation(AnimationsStorage.Walk), 		AttackAnimation = Aimator:LoadAnimation(AnimationsStorage.Attack),		ClimbingAnimation = Aimator:LoadAnimation(AnimationsStorage.Climb),		IdleAnimation = Aimator:LoadAnimation(AnimationsStorage.Idle)}
	local NPCTable = {NPC = NPC, Animations = AnimationsTable, Settings = {WalkSpeed = NPC.Humanoid.WalkSpeed}}
	AnimationsTable.IdleAnimation:Play()
	table.insert(_G.NPCs, NPCTable)
	return self
end
function NPCS.New(Data)
	local self,Aimator, AnimationsStorage  = setmetatable({}, NPCS), Data.NPC.Humanoid.Animator, game.ServerStorage.Animations.Zombies.Slow
	local AnimationsTable = { 		WalkAnimation = Aimator:LoadAnimation(AnimationsStorage.Walk), 		AttackAnimation = Aimator:LoadAnimation(AnimationsStorage.Attack),		ClimbingAnimation = Aimator:LoadAnimation(AnimationsStorage.Climb),		IdleAnimation = Aimator:LoadAnimation(AnimationsStorage.Idle)}
	local NPCTable = {NPC = Data.NPC, Animations = AnimationsTable, Settings = {WalkSpeed = Data.NPC.Humanoid.WalkSpeed}}
	table.insert(_G.NPCs, NPCTable)
	AnimationsTable.IdleAnimation:Play()
	SetCollisionGroup(Data.NPC)
	return self
end
task.spawn(function()
	while task.wait() do
		for i, v in ipairs(_G.NPCs) do
			task.spawn(function()
				local NPC = v.NPC
				if NPC:GetAttribute("Ragdoll") then
					for _, anim in v.Animations do
						if anim.IsPlaying then anim:Stop() end
					end
					return
				end
				local nearestChar, nearestBlock = Nearest.GetNearestPlayer(NPC), Nearest.NearestBlock(NPC)
				if not NPC or not NPC.PrimaryPart or not nearestChar or not nearestChar.PrimaryPart then return end
				if NPC:GetAttribute("PathBlocked") then NPC.Humanoid.WalkSpeed = 0 else NPC.Humanoid.WalkSpeed = v.Settings.WalkSpeed  end
				if v.State == "Attacking" then NPC.Humanoid.WalkSpeed = 0 end
				local npcPos, charPos = NPC.PrimaryPart.Position, nearestChar.PrimaryPart.Position
				local distToChar = (charPos - npcPos).Magnitude
				if nearestBlock then
					local blockPos = nearestBlock.PrimaryPart.Position
					if (blockPos - npcPos).Magnitude <= 25 then
						if NPC:GetAttribute("PathBlocked") then return end
						local startPos, dir = npcPos + NPC.PrimaryPart.CFrame.LookVector, NPC.PrimaryPart.CFrame.LookVector
						local rayResult = workspace:Raycast(startPos, dir, RaycastParams.new { FilterDescendantsInstances = {game.Workspace.Alive}, FilterType = Enum.RaycastFilterType.Exclude })
						if rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(workspace.MAP.PathBlock) then
							Attack.DestroyBlock(NPC, nearestBlock, i)
							NPC:SetAttribute("PathBlocked", true)
						else
							NPC:SetAttribute("PathBlocked", nil)
						end
					else
						NPC:SetAttribute("PathBlocked", nil)
					end
				end
				if not NPC:GetAttribute("PathBlocked") then
					if not NPC:GetAttribute("Following") then PathFind.PathFind(NPC, nearestChar, i) end
					if distToChar <= 10 then
						if NPCSight.CheckSight(NPC, nearestChar, 120) then
							NPC:SetAttribute("Following", true)
							if distToChar <= 3 then Attack.Attack(NPC, nearestChar, i) end
							NPC.Humanoid:MoveTo(charPos + Seperation.getSeparationForce(NPC))
							v.State = "Running"
						else
							NPC:SetAttribute("Following", nil)
						end
					else
						NPC:SetAttribute("Following", nil)
					end
				end
				local walkAnim = v.Animations.WalkAnimation
				if v.State ~= "Running" and walkAnim.IsPlaying then
					walkAnim:Stop()
					if v.State == "Idle" or v.State == "Attacking" then NPC.Humanoid.WalkSpeed = 0 end
				elseif v.State == "Running" and not walkAnim.IsPlaying then
					walkAnim:Play()
					NPC.Humanoid.WalkSpeed = v.Settings.WalkSpeed
				end
			end)
		end
	end
end)

return NPCS
