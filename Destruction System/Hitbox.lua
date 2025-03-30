local hitbox = {}
function hitbox.CreateHitBox(Data) 
	local Position = Data.Position or Vector3.new(1,11,1)
	local Size = Data.Size or Vector3.new(1,11,1)
	local Hitbox = Instance.new("Part")
	Hitbox.Parent = workspace.Ignored.Hitboxes
	Hitbox.Position = Position
	Hitbox.Size = Size
	Hitbox.Transparency = Data.Debug == true and 0.5 or 1
	Hitbox.Anchored = true
	Hitbox.CanQuery = false
	Hitbox.CanCollide = false
	Hitbox.CanTouch = false
	Hitbox.Material = Enum.Material.Neon
	Hitbox.Color = Color3.new(1, 0, 0)
	game:GetService("Debris"):AddItem(Hitbox, 0.3)
	return Hitbox
end
return hitbox
