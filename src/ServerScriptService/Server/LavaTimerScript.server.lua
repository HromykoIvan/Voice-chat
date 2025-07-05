-- LavaTimerScript (ServerScriptService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Создаём RemoteEvent, если его нет
local countdownEvent = ReplicatedStorage:FindFirstChild("EventCountdownTimer")
if not countdownEvent then
	countdownEvent = Instance.new("RemoteEvent")
	countdownEvent.Name = "EventCountdownTimer"
	countdownEvent.Parent = ReplicatedStorage
end

-- Настройки
local INTERVAL = 620 -- интервал между волнами лавы
local RISE_TIME = 10
local FALL_TIME = 10
local STEP_INTERVAL = 0.2
local MAX_HEIGHT = 2

-- Состояние
local lavaPart = nil
local touchConn = nil
local lastLavaStartTime = 0

-- 🔁 Обновление для новых игроков
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		countdownEvent:FireClient(player, "lavaStart", lastLavaStartTime, INTERVAL)
	end)
end)

-- 🔥 Создание и движение лавы
local function removeLava()
	if touchConn then
		touchConn:Disconnect()
		touchConn = nil
	end
	if lavaPart and lavaPart.Parent then
		lavaPart:Destroy()
		lavaPart = nil
	end
end

local function moveLava(duration, direction)
	local steps = math.floor(duration / STEP_INTERVAL)
	local deltaY = MAX_HEIGHT / steps
	if direction == "down" then deltaY = -deltaY end

	for _ = 1, steps do
		if lavaPart and lavaPart.Parent then
			lavaPart.Position += Vector3.new(0, deltaY, 0)
		end
		task.wait(STEP_INTERVAL)
	end
end

local function spawnLava()
	removeLava()

	lavaPart = Instance.new("Part")
	lavaPart.Name = "RisingLava"
	lavaPart.Size = Vector3.new(1000, 1, 1000)
	lavaPart.Position = Vector3.new(0, 0.5, 0)
	lavaPart.Anchored = true
	lavaPart.BrickColor = BrickColor.new("Bright red")
	lavaPart.Material = Enum.Material.Neon
	lavaPart.CanCollide = true
	lavaPart.Parent = workspace

	touchConn = lavaPart.Touched:Connect(function(part)
		local model = part:FindFirstAncestorOfClass("Model")
		if model then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end)

	moveLava(RISE_TIME, "up")
	task.wait(1)
	moveLava(FALL_TIME, "down")
	task.wait(1)
	removeLava()
end

-- 🔁 Основной цикл
while true do
	lastLavaStartTime = tick()
	countdownEvent:FireAllClients("lavaStart", lastLavaStartTime, INTERVAL)
	print("🌋 SERVER SEND lavaStart", lastLavaStartTime, INTERVAL)

	task.wait(INTERVAL)
	countdownEvent:FireAllClients("lavaAttack")
	print("🔥 SERVER SEND lavaAttack")

	spawnLava()
end
