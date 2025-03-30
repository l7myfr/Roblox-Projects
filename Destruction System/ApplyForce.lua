local module = {}
local Settings = require(script.Parent.Settings)
local RS = game:GetService("RunService")

-- Figures out the direction to apply force
local function CalculateDirection(Data)
	if not Data.DirectionPart then return end
	return Data.DirectionPart.CFrame.LookVector
end
local function ApplyForce(oppositeDirection, partToApplyForceTo, Force)

	if oppositeDirection and partToApplyForceTo and partToApplyForceTo.Anchored == false then
		partToApplyForceTo.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		partToApplyForceTo.AssemblyLinearVelocity += oppositeDirection * Force 
		if Settings.AnchorThePart then
			local Connection
			Connection = RS.Heartbeat:Connect(function()
				if partToApplyForceTo.AssemblyLinearVelocity == Vector3.new(0, 0, 0) then
					partToApplyForceTo.Anchored = true
					partToApplyForceTo.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					Connection:Disconnect()
				end
				if partToApplyForceTo.Anchored == true then
					partToApplyForceTo.Anchored = true
					partToApplyForceTo.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					Connection:Disconnect()
				end
			end)
			partToApplyForceTo.Destroying:Connect(function()
				if Connection then
					Connection:Disconnect()
				end
			end)
		end
	end
end
local function AddVelocity(Data, partToApplyForceTo: Part)
	local Force = Data.Force or Settings.Force
	local oppositeDirection = CalculateDirection(Data)

	if Data.DirectionPart  and partToApplyForceTo then
		local partPosition = Data.DirectionPart.Position
		partPosition = Vector3.new(partPosition.X, partPosition.Y - 2.5 , partPosition.Z)
		--[[local Part = Instance.new("Part")
		Part.Parent = workspace.Ignored
		Part.Anchored = true
		Part.CanCollide = false
		Part.Transparency = 0.5
		Part.Color = Color3.new(1, 0, 0)
		Part.Size = Vector3.one
		Part.Position = partPosition]]
		local partToApplyForceToPosition = partToApplyForceTo.Position
		local UnanchorIfBelow = Data.UnanchorIfBelow
		if partToApplyForceToPosition.Y > partPosition.Y and UnanchorIfBelow == false then
			ApplyForce(oppositeDirection, partToApplyForceTo, Force)
		elseif UnanchorIfBelow ==  true then
			ApplyForce(oppositeDirection, partToApplyForceTo, Force)
		elseif not UnanchorIfBelow then
			ApplyForce(oppositeDirection, partToApplyForceTo, Force)
		end
		if partToApplyForceToPosition.Y < partPosition.Y and UnanchorIfBelow == false then
			partToApplyForceTo.Anchored = true
		end
	end
end




function module:ApplyForce(Data, partToApplyForceTo)
	AddVelocity(Data, partToApplyForceTo)
end

return module
