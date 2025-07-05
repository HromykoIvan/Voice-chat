local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MY_ID = 1755928143 -- твой ID
local AdminIds = {
	[1755928143] = true,
	[2955006633] = true
}
-- Ждём RemoteEvent, если он уже создан на сервере
local remote = ReplicatedStorage:WaitForChild("DebugAddTime")

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if AdminIds[player.UserId] and input.KeyCode == Enum.KeyCode.KeypadPlus  or input.KeyCode == Enum.KeyCode.F8 then
		remote:FireServer(5)
	end
end)
