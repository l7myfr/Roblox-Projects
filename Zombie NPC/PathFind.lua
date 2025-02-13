local module = {}
local Seperation = require(script.Parent.Seperation)
local Nearest = require(script.Parent.Nearest)

function module.PathFind(NPC, Target, v, retryAttempts)
	if not NPC then return end
	if not NPC.PrimaryPart then return end
	if not Target then return end
	if not Target.PrimaryPart then return end

	retryAttempts = retryAttempts or 0
	local path = game.PathfindingService:CreatePath({
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = true,
		AgentCanClimb = true,
		Costs = {
		}
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(NPC.PrimaryPart.Position, Target.PrimaryPart.Position)
	end)

	local State = _G.NPCs[v]
	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for i, v in waypoints do
		--[[local Part = Instance.new("Part")
			Part.Anchored = true
			Part.CanCollide = false
			Part.CanQuery = false
			Part.CanTouch = false
			Part.Position = v.Position
			Part.Parent = game.Workspace
			Part.Shape = Enum.PartType.Ball
			Part.Transparency = 0.5
			Part.Color = Color3.new(0.45098, 0, 1)
			game:GetService("Debris"):AddItem(Part, 0.1)]]
			
		end
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
return module
