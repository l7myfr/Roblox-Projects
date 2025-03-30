setup in studio like this

ReplicatedStorage
│── VoxelDestruction
│   ├── Events
│   │   ├── RegenerationTask
│   ├── Destruction
│   │   ├── Misc
│   │   │   ├── FadeOut
│   │   ├── Regeneration
│   │   │   ├── NewTask
│   │   │   ├── Regenerate
│   ├── ApplyForce
│   ├── Hitbox
│   ├── Settings
│   ├── SplitUp


use like this


local Playerr : Player = game.Players.LocalPlayer
local Character : Model = Playerr.Character or Playerr.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local VoxelDestruction = require(game.ReplicatedStorage.VoxelDestruction.Destruction)
local HitBox = Instance.new("Part")
HitBox.Size = Vector3.new(9, 7, 9) 
HitBox.Anchored = true
HitBox.CanCollide = false
HitBox.Transparency = 0.5
HitBox.BrickColor = BrickColor.new("Bright red") 

local forwardOffset = 4
local frontCFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -forwardOffset)

HitBox.CFrame = frontCFrame

HitBox.Parent = workspace.Ignored.Hitboxes

game.Debris:AddItem(HitBox, 0.1)
local Data = {
    Hitbox = HitBox,
    Force = 60,
    ApplyForce = true, 
    DirectionPart = HumanoidRootPart,
    Player = Playerr,
    GoalSize = 2.5,
    SpawnVoxels = true,
    FadeOutSize = 0.5,
    FadeOutTime = 4,
    FadeOut = true,
    UnanchorIfBelow = false,
    RegenerationTime = 100,

}
VoxelDestruction:StartVoxelDestruction(Data)