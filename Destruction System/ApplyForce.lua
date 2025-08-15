
local module = {}

--// Services & Modules
local RS = game:GetService("RunService")
local Settings = require(script.Parent.Settings)

--// Constants
local ZERO_VECTOR3 = Vector3.new(0, 0, 0)

--// Connects to Heartbeat to anchor a part once it stops moving.
local function anchorOnStop(part)
	local connection
	connection = RS.Heartbeat:Connect(function()
		if not part.Parent or part.Anchored or part.AssemblyLinearVelocity == ZERO_VECTOR3 then
			if part and part.Parent then
				part.Anchored = true
				part.AssemblyLinearVelocity = ZERO_VECTOR3
			end
			connection:Disconnect()
		end
	end)
	part.Destroying:Connect(function() connection:Disconnect() end)
end

--// Main function to apply directional force to a part.
function module:ApplyForce(Data, partToApplyForceTo)
	if not Data or not partToApplyForceTo or not partToApplyForceTo.Parent or not Data.DirectionPart then
		return
	end

	local yThreshold = Data.DirectionPart.Position.Y - 2.5

	if not Data.UnanchorIfBelow and partToApplyForceTo.Position.Y <= yThreshold then
		partToApplyForceTo.Anchored = true
		return
	end

	if partToApplyForceTo.Anchored then
		partToApplyForceTo.Anchored = false
	end

	local force = Data.Force or Settings.Force
	local direction = Data.DirectionPart.CFrame.LookVector

	partToApplyForceTo.AssemblyLinearVelocity += direction * force

	if Settings.AnchorThePart then
		anchorOnStop(partToApplyForceTo)
	end
end

return module
