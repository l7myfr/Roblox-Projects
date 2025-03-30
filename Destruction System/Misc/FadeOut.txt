local module = {}
local Settings = require(script.Parent.Parent.Settings)
local TweenService = game:GetService("TweenService")
local function StartFadeOut(Data, Part)
	local FadeOutTime = Data.FadeOutTime or Settings.FadeOutTime
	local TweenInfo = TweenInfo.new(
	   FadeOutTime,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)
	local Transparencytween = TweenService:Create(Part, TweenInfo, {Transparency = 1})
	Transparencytween:Play()
	Transparencytween.Completed:Connect(function()
		Part:Destroy()
	end)
end
local function CanFadeOut(Data, Part : Part)
	local Size = Data.FadeOutSize or Settings.FadeOutMinSize 
	
	if Part.Size.X < Size * 5 and Part.Size.Y < Size * 4 and Part.Size.Z < Size * 5 then
		return true
	end
	return false
end

function module:FadeOut(Data, Part)
	if CanFadeOut(Data, Part) then
		task.delay(5, function()
			StartFadeOut(Data, Part)
		end)
	end
end
return module
