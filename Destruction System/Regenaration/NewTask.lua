local module = {}
local RegenerateModule = require(script.Parent.Regenerate)
local RunService = game:GetService("RunService")
local Tasks = {}
Tasks.__index = Tasks
module.__index = module

function module.New(Data)

	if not Data.VoxelHolder or not Data.RegenerationTime then return end 
	local self = setmetatable({}, module)
	self.Object = Data.VoxelHolder.PrimaryPart
	self.RegenerateFunction = RegenerateModule.New(self.Object)

	self.RegenerationTime = Data.RegenerationTime 

	self:Start()
	return self
end

function module:Start()
	if Tasks[self.Object] and Tasks[self.Object].TimeLeft and Tasks[self.Object].TimeLeft > self.RegenerationTime then
		return 
	end

	if Tasks[self.Object] then
		task.cancel(Tasks[self.Object].Handle)
		Tasks[self.Object] = nil
	end
	if not Tasks[self.Object]  then
		Tasks[self.Object] = {
			TimeLeft = self.RegenerationTime,
		}
		Tasks[self.Object].Handle = task.spawn(function()
			while Tasks[self.Object] and Tasks[self.Object].TimeLeft > 0 do
				local dt = RunService.Heartbeat:Wait() 
				Tasks[self.Object].TimeLeft = Tasks[self.Object].TimeLeft - dt
			end

			if Tasks[self.Object] and Tasks[self.Object].TimeLeft <= 0 then
				self.RegenerateFunction:Regenerate()
			end
			Tasks[self.Object] = nil

		end)
	end

end

return module
