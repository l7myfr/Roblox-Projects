local Divider = {}
local Settings = require(script.Parent.Settings)
local Atbs = {
	"CastShadow",
	"CanCollide",
	"Transparency",
	"CanQuery",
	"CanTouch"
}
local Regeneration = require(script.Parent.Regenaration.NewTask)


-- Checks if the object can be divided

local function IsDivisible(object: Part) -- checks conditions to see if the part is  able to be divided
	if not object then return false end
	if not object:IsA("Part") then return false end
	if object.Shape ~= Enum.PartType.Block then return false end
	if object:IsDescendantOf(game.Workspace.Ignored.Alive) then return false end
	return true
end

-- Copies over all relevant attributes from one part to another
local function TransferAttributes(destination: Part, source: Part)
	destination.Color = source.Color
	destination.Material = source.Material
	destination.Transparency = source.Transparency
	destination.Parent =  source.Parent
	destination.CanCollide = true
	destination.Anchored = true
	destination.TopSurface = source.TopSurface or Enum.SurfaceType.Plastic
	destination.BottomSurface = source.BottomSurface or Enum.SurfaceType.Plastic
	destination.BackSurface = source.BackSurface or Enum.SurfaceType.Plastic
	destination.FrontSurface = source.FrontSurface or Enum.SurfaceType.Plastic
	destination.RightSurface = source.RightSurface or Enum.SurfaceType.Plastic
	destination.LeftSurface = source.LeftSurface or Enum.SurfaceType.Plastic
end

-- Makes a duplicate of the given part

local function DuplicatePart(originalPart: Part, Data)
	local newPart = Instance.new("Part")
	TransferAttributes(newPart, originalPart, Data)
	return newPart
end


-- Makes a new model called "VoxelHolder" to keep stuff organized


local function CreateAParent(Object:Part, Data) -- Creates a "VoxelHolder" Parent for it to stay organized
	local VoxelHolder
	if Object.Parent.Name ~= "VoxelHolder" then
		VoxelHolder = Instance.new("Model")
		VoxelHolder.Parent = Object.Parent
		VoxelHolder.Name = "VoxelHolder"
		Object.Parent = VoxelHolder
		local Newpart = Object:Clone()
		Newpart:AddTag("RegenPart")
		Newpart.CanQuery = false
		Newpart.Anchored = true
		Newpart.CanCollide = false
		Newpart.Transparency = 1
		Newpart.Parent = VoxelHolder
		VoxelHolder:AddTag("VoxelHolder")
		for i,v in Atbs do
			Newpart:SetAttribute(v, Object[v])
		end
		VoxelHolder.PrimaryPart = Newpart
	else
		VoxelHolder = Object.Parent
		VoxelHolder:AddTag("VoxelHolder")
	end
	VoxelHolder:AddTag("VoxelHolder")
	VoxelHolder.Name = "VoxelHolder"


	Data.VoxelHolder = VoxelHolder
	Regeneration.New(Data)
end



local function CutPart(originalPart: Part, axis, Data) -- the part is cut on the longest axis
    CreateAParent(originalPart, Data)
	


	local PartOne = DuplicatePart(originalPart, Data)
	local PartTwo = DuplicatePart(originalPart, Data) 
	-- creates 2 Parts to be sized and positioned
	local axisSize 
	if axis == "X" then
		axisSize = Vector3.new(1, 0, 0)
	elseif axis == "Y"then
		axisSize = Vector3.new(0, 1, 0)
	else
		axisSize = Vector3.new(0, 0, 1)
	end

	PartOne.Size = originalPart.Size * (-(axisSize/2)+Vector3.new(1,1,1))
	PartOne.CFrame = originalPart.CFrame * CFrame.new(-originalPart.Size * (Vector3.new(1,1,1)*axisSize/4))	

	PartTwo.Size = originalPart.Size * (-(axisSize/2)+Vector3.new(1,1,1))
	PartTwo.CFrame = originalPart.CFrame * CFrame.new(originalPart.Size * (Vector3.new(1,1,1)*axisSize/4))	
	
	if Settings.Debug == true then
		PartTwo.Color = Color3.new(math.random(1, 360), math.random(1, 360),math.random(1, 360))
		PartOne.Color = Color3.new(math.random(1, 360), math.random(1, 360),math.random(1, 360))
	end
	return PartOne, PartTwo -- and then returns the 2 parts
end


function Divider:DividePart(object, Data) 
	if not IsDivisible(object) then return false end
	local goalSize = Data.GoalSize or Settings.GoalSize -- size limit for the part

	-- Check if part is too small to be cut again

	if object.Size.X/ 2 <= goalSize and object.Size.Y / 2 <= goalSize and object.Size.Z /2.5  <= goalSize then
		CreateAParent(object, Data)
		return false
	end

	local dominantAxis
	local axis = math.max(object.Size.X, object.Size.Y, object.Size.Z)
	if axis == object.Size.X then
		dominantAxis = "X"
	elseif axis == object.Size.Y then
		dominantAxis = "Y"
	else
		dominantAxis = "Z"
	end
	local PartOne, PartTwo = CutPart(object, dominantAxis, Data)
	object:Destroy()

	return true
end

return Divider
