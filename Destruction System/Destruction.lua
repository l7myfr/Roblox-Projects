-- PARENT EVERY SCRIPT AND FOOLDER TO ME!!!!!!

local Destruction = {}
local Settings = require(script.Settings)
local Force = require(script.ApplyForce)
local Divison = require(script.SplitUp)
local RS = game:GetService("RunService")
local HitBoxModule = require(script.Hitbox)
local FadeOutModule = require(script.Misc.FadeOut)
local function PartsInBound(Part)

	if not Part then warn("No Part") return end
	local Parts = workspace:GetPartsInPart(Part, Settings.OverlapParams)

	return Parts
end

function Destruction:StartVoxelDestruction(Data)
	local Parts 
	repeat
		Parts = PartsInBound(Data.Hitbox)

		local Hitbox = Data.Hitbox  do
			if not Data.Hitbox then 
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanQuery = false
				part.CanCollide = false
				part.CanTouch = false
			end
		end
		local PartsNew = {}
		for i = 1, #Parts do
			if not Parts[i] then Parts[i] = nil continue end
			if not Parts[i]:IsA("Part") then Parts[i] = nil  continue end
			PartsNew[Parts[i]] = true
			if  Parts[i].Shape ~= Enum.PartType.Block then Parts[i] = nil continue end
			if Parts[i]:HasTag("RegenPart") then -- if the part has RegenPart tag then it will be removed from the table
				Parts[i] = nil
				PartsNew[Parts[i]] = nil
				continue
			end
			if Parts[i]:IsDescendantOf(game.Workspace.Ignored.Map.Undestructable) then 
				Parts[i] = nil
				PartsNew[Parts[i]] = nil
				continue
			end
			if Parts[i]:IsDescendantOf(game.Workspace.Ignored.Alive)  then 
				Parts[i] = nil
				PartsNew[Parts[i]] = nil
				continue
			end
			local Split = Divison:DividePart(Parts[i], Data) -- Divides the part
			if not Split then --- if the part is not split than that means that the part is the goal size
				local SpawnVoxels = Data.SpawnVoxels 
				local Part : Part = Parts[i]
				Parts[i] = nil
				if not Part then return end
				if SpawnVoxels== true then
					Part.Anchored = false
				else
					Part:Destroy()
					PartsNew[Part] = nil
				end

				if Data.Player and Data.Player:IsA("Player") and SpawnVoxels == true and RS:IsServer() then -- if we provide the player value in data then it will set networkowner
					Part:SetNetworkOwner(Data.Player)
				end
				if Settings.SetPartToMassless == true and SpawnVoxels == true then -- if the Settings.SetPartToMassless is set to true it will set the part to massless
					Part.Massless = true
				end
				if Data.ApplyForce == true and  SpawnVoxels == true then -- if we pass on "ApplyForce" as a true value then it will apply the force
					Force:ApplyForce(Data, Part)
				end

				if SpawnVoxels == true and Data.FadeOut then
					FadeOutModule:FadeOut(Data, Part)
				end
				if SpawnVoxels == false then
					Part:Destroy()
					PartsNew[Part] = nil
				end
				local Connection
				if  Data.ApplyForce == false or not Data.ApplyForce then
					Connection = RS.Heartbeat:Connect(function()
						if Part.Anchored == true then
							Connection:Disconnect()
						end
						if Part.AssemblyLinearVelocity == Vector3.new(0, 0, 0) then
							Part.Anchored = true
							Part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
							Connection:Disconnect()
						end
					end)
				end
				Part.Destroying:Connect(function()
					PartsNew[Part] = nil
					if Connection then
						Connection:Disconnect()
					end
				end)
			end
		end
		RS.Heartbeat:Wait()
	until #Parts == 0
end


return Destruction
