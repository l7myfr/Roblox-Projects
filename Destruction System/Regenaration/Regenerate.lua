local module = {}
local ObjectPooler = require(script.Parent.Parent.ObjectPooler)

local Atbs = {
	"CastShadow",
	"CanCollide",
	"Transparency",
	"CanQuery",
	"CanTouch"
}
module.__index = module
function module.New(Object)
	local self = setmetatable({},module)
	self.Object = Object
	self.VoxelHolder = Object.Parent
	return self
end
function module:CopyPropeties()
	for i, v in Atbs do
		self.Object[v]  = self.Object:GetAttribute(v)
	end
end
function module:Regenerate()
	self.Object.Parent = self.Object.Parent.Parent
	for _, Part in self.VoxelHolder:GetChildren() do
		if Part:IsA("Part") then
			ObjectPooler.ReturnInstance(Part)
		end
	end
	self.VoxelHolder:Destroy()

	if self.Object:HasTag("RegenPart") then
		self.Object:RemoveTag("RegenPart")
	end
	
	self:CopyPropeties()
end
return module
