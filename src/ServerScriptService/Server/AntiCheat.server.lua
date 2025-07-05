local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Lighting.DescendantAdded:Connect(function(obj)
	if obj:IsA("Sky") and obj.Name ~= "SafeSky" then
		warn("Удалено читерское небо")
		obj:Destroy()
	end
end)

-- 🎧 Звуки вне контроля
Lighting.DescendantAdded:Connect(function(obj)
	if obj:IsA("Sound") then
		warn("Удалён подозрительный звук в Lighting")
		obj:Destroy()
	end
end)

-- 🧼 RemoteEvent фильтрация
local function cleanRemotes()
	for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			local name = obj.Name:lower()
			if name:find("kill") or name:find("explode") or name:find("admin") then
				warn("Удалён Remote: " .. obj.Name)
				obj:Destroy()
			end
		end
	end
end
cleanRemotes()

-- 🔁 Проверка каждые 60 секунд на случай повторной вставки
while true do
	wait(60)
	cleanRemotes()
end