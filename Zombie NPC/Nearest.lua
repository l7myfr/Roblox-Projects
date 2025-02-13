local module = {}
function module.NearestBlock(NPC)
	local nearestBlock = nil
	local shortestDistance = math.huge
	local npc = NPC
	local npcHRP = npc and npc:FindFirstChild("HumanoidRootPart")

	if not npcHRP then return nil end

	for _, Block in ipairs(game.Workspace.MAP.PathBlock:GetChildren()) do
		local PrimaryPart = Block.PrimaryPart
		local distance = (PrimaryPart.Position - npcHRP.Position).Magnitude

		if distance < shortestDistance then
			nearestBlock = Block
			shortestDistance = distance
		end
	end
	return nearestBlock
end
function module.GetNearestPlayer(NPC, excludedPlayers)
	local nearestCharacter = nil
	local shortestDistance = math.huge
	local npc = NPC
	local npcHRP = npc and npc:FindFirstChild("HumanoidRootPart")
	excludedPlayers = excludedPlayers or {}
	if not npcHRP then return nil end

	for _, player in ipairs(game.Players:GetPlayers()) do
		if not excludedPlayers[player] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local charHRP = player.Character.HumanoidRootPart
			local distance = (charHRP.Position - npcHRP.Position).Magnitude

			if distance < shortestDistance then
				nearestCharacter = player.Character
				shortestDistance = distance
			end
		end
	end
	return nearestCharacter
end

return module
