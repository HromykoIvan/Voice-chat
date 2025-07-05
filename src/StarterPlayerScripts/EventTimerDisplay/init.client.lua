-- ⚙️ Сервисы
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- 📱 Детектируем мобилу
local isMobile = UserInputService.TouchEnabled
local baseSize = isMobile and UDim2.new(0.15, 0, 0.04, 0) or UDim2.new(0.06, 0, 0.03, 0)
local baseTextSize = isMobile and 8 or 14
local baseOffset = isMobile and -100 or -140
local spacing = isMobile and 20 or 40


-- 🧱 GUI контейнер
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EventTimersGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local baseFont = Enum.Font.Code -- Моноширинный шрифт

-- 🔥 Lava таймер
local lavaLabel = Instance.new("TextLabel")
lavaLabel.Size = baseSize
lavaLabel.Position = UDim2.new(1, -10, 1, baseOffset)
lavaLabel.AnchorPoint = Vector2.new(1, 1)
lavaLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lavaLabel.BackgroundTransparency = 0.3
lavaLabel.BorderSizePixel = 0
lavaLabel.TextColor3 = Color3.fromRGB(255, 85, 0)
lavaLabel.TextSize = baseTextSize
lavaLabel.Font = baseFont
lavaLabel.Text = "LAVA [00:00]"
lavaLabel.TextXAlignment = Enum.TextXAlignment.Center
lavaLabel.TextYAlignment = Enum.TextYAlignment.Center
lavaLabel.TextWrapped = false
lavaLabel.Parent = screenGui

-- 🎶 Disco таймер
local discoLabel = Instance.new("TextLabel")
discoLabel.Size = baseSize
discoLabel.Position = UDim2.new(1, -10, 1, baseOffset + spacing)
discoLabel.AnchorPoint = Vector2.new(1, 1)
discoLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
discoLabel.BackgroundTransparency = 0.3
discoLabel.BorderSizePixel = 0
discoLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
discoLabel.TextSize = baseTextSize
discoLabel.Font = baseFont
discoLabel.Text = "DISCO [00:00]"
discoLabel.TextXAlignment = Enum.TextXAlignment.Center
discoLabel.TextYAlignment = Enum.TextYAlignment.Center
discoLabel.TextWrapped = false
discoLabel.Parent = screenGui


-- ⚠️ Lava alert
local alertLabel = Instance.new("TextLabel")
alertLabel.Size = UDim2.new(0.6, 0, 0.15, 0)
alertLabel.Position = UDim2.new(0.2, 0, 0.42, 0)
alertLabel.BackgroundTransparency = 1
alertLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
alertLabel.TextStrokeTransparency = 0
alertLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
alertLabel.Font = Enum.Font.GothamBlack
alertLabel.TextScaled = true
alertLabel.Text = ""
alertLabel.Visible = false
alertLabel.Parent = screenGui

-- 💬 Disco message
local discoMsg = Instance.new("TextLabel")
discoMsg.Size = UDim2.new(1, 0, 0.2, 0)
discoMsg.Position = UDim2.new(0, 0, 0.4, 0)
discoMsg.BackgroundTransparency = 0.3
discoMsg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
discoMsg.TextColor3 = Color3.fromRGB(255, 255, 255)
discoMsg.Font = Enum.Font.SourceSansBold
discoMsg.TextScaled = true
discoMsg.Visible = false
discoMsg.Parent = screenGui

-- 🎵 Музыка и анимации
local musicIds = {
	"rbxassetid://1840434670",
	"rbxassetid://1845092181",
}

local danceAnimations = {
	"rbxassetid://507771019",
	"rbxassetid://507776043",
	"rbxassetid://507777268",
	"rbxassetid://507770239",
	"rbxassetid://507765000",
}

local colors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(0, 255, 255)
}

local discoDuration = 100
local eventTimerEvent = ReplicatedStorage:WaitForChild("EventCountdownTimer")
local discoEvent = ReplicatedStorage:WaitForChild("StartDiscoEvent")

-- 📦 Таймер переменные
local lavaStartTime = 0
local lavaInterval = 600
local lastSecondShown = -1
local lavaAlertShown = false

-- 🔄 Событие таймера
eventTimerEvent.OnClientEvent:Connect(function(eventName, a, b)
	if eventName == "lavaStart" then
		lavaStartTime = a
		lavaInterval = b or 600
		lastSecondShown = -1
		lavaAlertShown = false

	elseif eventName == "lavaAttack" then
		alertLabel.Text = "🌋 ЛАВА НАСТУПАЕТ!"
		alertLabel.Visible = true
		task.delay(2, function()
			alertLabel.Visible = false
		end)

	elseif eventName == "disco" then
		local seconds = math.floor(a)
		local minutes = math.floor(seconds / 60)
		local rem = seconds % 60
		discoLabel.Text = string.format("DISCO [%02d:%02d]", minutes, rem)
	end
end)

-- ⏱️ Обновление Lava таймера
RunService.RenderStepped:Connect(function()
	if lavaStartTime == 0 then return end

	local now = tick()
	local timeLeft = math.max(0, lavaStartTime + lavaInterval - now)
	local seconds = math.floor(timeLeft)
	local minutes = math.floor(seconds / 60)
	local rem = seconds % 60
	lavaLabel.Text = string.format("LAVA [%02d:%02d]", minutes, rem)

	if seconds <= 5 and seconds >= 1 and seconds ~= lastSecondShown then
		lastSecondShown = seconds
		alertLabel.Text = tostring(seconds)
		alertLabel.Visible = true
		task.delay(1, function()
			if lastSecondShown == seconds then
				alertLabel.Visible = false
			end
		end)
	end
end)

-- 🎉 Диско начинается
discoEvent.OnClientEvent:Connect(function(buyerName)
	print("🎉 ДИСКОТЕКА НАЧАЛАСЬ!")

	discoMsg.Text = "🔥 " .. buyerName .. " купил дискотеку! 🔥"
	discoMsg.Visible = true
	task.delay(1, function()
		discoMsg.Visible = false
	end)

	local musicId = musicIds[math.random(1, #musicIds)]
	local sound = Instance.new("Sound")
	sound.SoundId = musicId
	sound.Looped = true
	sound.Volume = 1
	sound.Parent = SoundService
	sound:Play()

	local animId = danceAnimations[math.random(1, #danceAnimations)]
	local anim = Instance.new("Animation")
	anim.AnimationId = animId

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local track = humanoid:LoadAnimation(anim)
	track.Looped = true
	track:Play()

	local endTime = tick() + discoDuration
	while tick() < endTime do
		Lighting.Ambient = colors[math.random(1, #colors)]
		Lighting.OutdoorAmbient = colors[math.random(1, #colors)]
		wait(0.2)
	end

	sound:Stop()
	track:Stop()
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

	print("✅ Дискотека закончилась!")
end)
