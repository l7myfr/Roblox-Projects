local module = {}
function module.Attack(NPC,target, i)
	local  NPCData = _G.NPCs[i]
	local NPC = NPCData.NPC
	local AttackAnimation = NPCData.Animations.AttackAnimation
	if AttackAnimation.IsPlaying then return end
	AttackAnimation:Play()
	local State = _G.NPCs[i]
	State.State = "Attacking"
	AttackAnimation.KeyframeReached:Once(function(KeyFrame)
		if KeyFrame == "Attack" then
			local Hitbox = Instance.new("Part")
			Hitbox.Parent = game.Workspace.MAP.Hitboxs
			Hitbox.Anchored = true
			Hitbox.CanCollide = false
			Hitbox.CanQuery = false
			Hitbox.CanTouch = false
			Hitbox.Transparency = 0.5
			Hitbox.Size = Vector3.new(4,5,4)
			Hitbox.Color = Color3.new(1, 0, 0)
			local NPCRoot = NPC.PrimaryPart or NPC:FindFirstChild("HumanoidRootPart")
			Hitbox.CFrame = NPCRoot.CFrame * CFrame.new(0, 0, -3)
			local OverLapParams = OverlapParams.new()
			OverLapParams.FilterType = Enum.RaycastFilterType.Include
			OverLapParams.FilterDescendantsInstances = {game.Workspace.Alive.Players}
			local Humanoids = {}
			if Hitbox then
				local OverlappingParts = workspace:GetPartsInPart(Hitbox, OverLapParams)

				for _, part in pairs(OverlappingParts) do
					local Character = part.Parent
					local Humanoid = Character and Character:FindFirstChild("Humanoid")
					if not table.find(Humanoids, Humanoid) then
						table.insert(Humanoids, Humanoid)
					end
				end
			end
			game:GetService("Debris"):AddItem(Hitbox, 1)
			for i,v  in Humanoids do
				if v then
					v:TakeDamage(20)
				end
			end
			AttackAnimation.Ended:Wait()

		end
		State.State = "Idle"
	end)

end

function module.DestroyBlock(NPC, target, i)
	if not NPC or not target then return end
	local Humanoid = NPC:FindFirstChild("Humanoid")
	if not Humanoid then return end

	task.spawn(function()
		local State = _G.NPCs[i]
		State.State = "Attacking" 

		while target and target.Parent do
			local AttackAnim : AnimationTrack = State.Animations.AttackAnimation
			AttackAnim:Play()
			AttackAnim.Ended:Wait()

			if target and target.Parent then
				local TargetHumanoid = target:FindFirstChild("Humanoid")
				if not TargetHumanoid then break end

				TargetHumanoid.Health -= 5
				if target:FindFirstChild("Wood Break") then
					target["Wood Break"]:Play()
				end

				if TargetHumanoid.Health <= 0 then
					target:Destroy()
					break 
				end
			else
				break
			end
		end

		State.State = "Idle"
		NPC:SetAttribute("PathBlocked", nil)
	end)
end

return module
