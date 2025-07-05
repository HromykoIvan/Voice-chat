local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Убедимся, что RemoteEvent существует
local eventTimerEvent = ReplicatedStorage:FindFirstChild("EventCountdownTimer")
if not eventTimerEvent then
	eventTimerEvent = Instance.new("RemoteEvent")
	eventTimerEvent.Name = "EventCountdownTimer"
	eventTimerEvent.Parent = ReplicatedStorage
end

-- Настройки
local musicId = "rbxassetid://142376088"
local danceAnimationId = "rbxassetid://507771019"
local discoDuration = 60
local waitTime = 420

local colors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(0, 255, 255)
}

-- Музыка
local discoMusic = Instance.new("Sound")
discoMusic.SoundId = musicId
discoMusic.Parent = SoundService
discoMusic.Looped = true
discoMusic.Volume = 1

-- Анимация
local danceAnim = Instance.new("Animation")
danceAnim.AnimationId = danceAnimationId

-- Анимация игрока
local function startDancing(player)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		local humanoid = char.Humanoid
		local animTrack = humanoid:LoadAnimation(danceAnim)
		animTrack.Looped = true
		animTrack.Name = "DiscoDance"
		animTrack:Play()
	end
end

local function stopDancing(player)
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
			if track.Name == "DiscoDance" then
				track:Stop()
			end
		end
	end
end

-- 🔁 Основной цикл
local lastStartTime = tick()

-- 👁 Отправка времени всем игрокам
task.spawn(function()
	while true do
		local now = tick()
		local timeLeft = math.max(0, lastStartTime + waitTime - now)
		eventTimerEvent:FireAllClients("disco", timeLeft)
		wait(1)
	end
end)

while true do
	local now = tick()
	local timeToWait = math.max(0, lastStartTime + waitTime - now)
	wait(timeToWait)

	print("🎉 ДИСКОТЕКА НАЧИНАЕТСЯ!")
	lastStartTime = tick()

	discoMusic:Play()
	for _, player in pairs(Players:GetPlayers()) do
		startDancing(player)
	end

	local discoStart = tick()
	while tick() - discoStart < discoDuration do
		Lighting.Ambient = colors[math.random(1, #colors)]
		Lighting.OutdoorAmbient = colors[math.random(1, #colors)]
		wait(0.2)
	end

	discoMusic:Stop()
	for _, player in pairs(Players:GetPlayers()) do
		stopDancing(player)
	end

	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	print("🕒 Дискотека окончена.")
end
