local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local PvPZone = workspace:WaitForChild("PvPZone")

local function isInZone(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		local size = PvPZone.Size / 2
		local center = PvPZone.Position
		return (
			math.abs(pos.X - center.X) <= size.X and
				math.abs(pos.Y - center.Y) <= size.Y and
				math.abs(pos.Z - center.Z) <= size.Z
		)
	end
	return false
end

game:GetService("RunService").Heartbeat:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			local hasSword = player.Backpack:FindFirstChild("Sword") or (character:FindFirstChild("Sword"))

			if isInZone(character) then
				if not hasSword then
					local swordClone = ServerStorage:FindFirstChild("Sword"):Clone()
					swordClone.Parent = player.Backpack
				end
			else
				if hasSword then
					hasSword:Destroy()
				end
			end
		end
	end
end)
