local NPCS = {}
local Seperation = require(script.Seperation)
local NPCSight = require(script.NPCSight)
local Nearest = require(script.Nearest)
local PathFind = require(script.PathFind)
local Attack = require(script.Attack)


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
	local NPC = script.Zombie:Clone()
	NPC.Parent = game.Workspace.Alive["NPC's"]
	SetCollisionGroup(NPC)
	local Aimator = NPC.Humanoid.Animator
	local AnimationsStorage = game.ServerStorage.Animations.Zombies.Slow
	local AnimationsTable = {
		WalkAnimation = Aimator:LoadAnimation(AnimationsStorage.Walk), 
		AttackAnimation = Aimator:LoadAnimation(AnimationsStorage.Attack),
		ClimbingAnimation = Aimator:LoadAnimation(AnimationsStorage.Climb),
		IdleAnimation = Aimator:LoadAnimation(AnimationsStorage.Idle)}
	local NPCTable = {NPC = NPC, Animations = AnimationsTable, Settings = {WalkSpeed = NPC.Humanoid.WalkSpeed}}
	AnimationsTable.IdleAnimation:Play()

	table.insert(_G.NPCs, NPCTable)
	return self
end


function NPCS.New(Data)
	local self = setmetatable({}, NPCS)
	local Aimator = Data.NPC.Humanoid.Animator
	local AnimationsStorage = game.ServerStorage.Animations.Zombies.Slow
	local AnimationsTable = { 
		WalkAnimation = Aimator:LoadAnimation(AnimationsStorage.Walk), 
		AttackAnimation = Aimator:LoadAnimation(AnimationsStorage.Attack),
		ClimbingAnimation = Aimator:LoadAnimation(AnimationsStorage.Climb),
		IdleAnimation = Aimator:LoadAnimation(AnimationsStorage.Idle)}
	local NPCTable = {NPC = Data.NPC, Animations = AnimationsTable, Settings = {WalkSpeed = Data.NPC.Humanoid.WalkSpeed}}
	table.insert(_G.NPCs, NPCTable)
	AnimationsTable.IdleAnimation:Play()
	SetCollisionGroup(Data.NPC)
	return self
end
local function visualizeRay(startPos, endPos)
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.2, 0.2, (startPos - endPos).Magnitude) 
	part.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -part.Size.Z / 2)
	part.Color = Color3.fromRGB(255, 0, 0) 
	part.Material = Enum.Material.Neon
	part.CanCollide = false
	part.Anchored = true
	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, 0.5)
end
task.spawn(function()
	while task.wait() do
		for i, v in ipairs(_G.NPCs) do
			task.spawn(function()
				local NPC = v.NPC
				if NPC:GetAttribute("Ragdoll") then
					for i, v in v.Animations do
						if v.IsPlaying then
							v:Stop()
						end
					end
					return
				end
				local nearestCharacter = Nearest.GetNearestPlayer(NPC)
				local nearestBlock = Nearest.NearestBlock(NPC)

				if not NPC or not NPC.PrimaryPart or not nearestCharacter or not nearestCharacter.PrimaryPart then
					return
				end
				if NPC:GetAttribute("PathBlocked") then
					NPC.Humanoid.WalkSpeed = 0
				end
				local npcPos = NPC.PrimaryPart.Position
				local charPos = nearestCharacter.PrimaryPart.Position
				local distanceToCharacter = (charPos - npcPos).Magnitude

				if nearestBlock then
					local blockPos = nearestBlock.PrimaryPart.Position
					if (blockPos - npcPos).Magnitude <= 25 then
						if NPC:GetAttribute("PathBlocked") then return end
						local npcPosition = NPC.PrimaryPart.Position + NPC.PrimaryPart.CFrame.LookVector * 1 
						local direction = NPC.PrimaryPart.CFrame.LookVector * 1
						local endPosition = npcPosition + direction

						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = {game.Workspace.Alive}
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude

						local rayResult = workspace:Raycast(npcPosition, direction, raycastParams)

						visualizeRay(npcPosition, endPosition)

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
					if not NPC:GetAttribute("Following") then
						PathFind.PathFind(NPC, nearestCharacter, i)
					end

					if distanceToCharacter <= 10 then
						if NPCSight.CheckSight(NPC, nearestCharacter, 120) then
							NPC:SetAttribute("Following", true)

							local separationForce = Seperation.getSeparationForce(NPC)
							if distanceToCharacter <= 3 then
								Attack.Attack(NPC, nearestCharacter, i)
							end

							NPC.Humanoid:MoveTo(charPos + separationForce)
							v.State = "Running"
						else
							NPC:SetAttribute("Following", nil)
						end
					else
						NPC:SetAttribute("Following", nil)
					end
				end

				local state = v.State
				local walkAnim = v.Animations.WalkAnimation
				if state ~= "Running" and walkAnim.IsPlaying then
					walkAnim:Stop()
					if state == "Idle" then
						NPC.Humanoid.WalkSpeed = 0
					end
					if state == "Attacking" then
						NPC.Humanoid.WalkSpeed = 0
					end
				elseif state == "Running"  then
					if not walkAnim.IsPlaying then
					walkAnim:Play()
					end
						NPC.Humanoid.WalkSpeed = v.Settings.WalkSpeed
				end
			end)
		end
	end
end)


return NPCS