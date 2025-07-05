local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local timeStore = DataStoreService:GetDataStore("PlayerTimePlayed")

local RANKS = {
	{Minutes = 200, Name = "БОГ сервера 🔥"},
	{Minutes = 150, Name = "Душа карты"},
	{Minutes = 120, Name = "Призрак Лавы"},
	{Minutes = 100, Name = "Герой сервера"},
	{Minutes = 70,  Name = "Маэстро"},
	{Minutes = 50,  Name = "Старейшина"},
	{Minutes = 35,  Name = "Прохожий 2.0"},
	{Minutes = 25,  Name = "Постоялец"},
	{Minutes = 15,  Name = "Игрок"},
	{Minutes = 10,  Name = "Новичок"},
	{Minutes = 5,   Name = "Гость"},
	{Minutes = 2,   Name = "Тень"},
	{Minutes = 0,   Name = "Безымянный"}
}

local RANK_COLORS = {
	["Безымянный"] = Color3.fromRGB(100, 100, 100),
	["Тень"] = Color3.fromRGB(120, 120, 120),
	["Гость"] = Color3.fromRGB(150, 150, 150),
	["Новичок"] = Color3.fromRGB(180, 180, 180),
	["Игрок"] = Color3.fromRGB(255, 255, 255),
	["Постоялец"] = Color3.fromRGB(85, 255, 127),
	["Прохожий 2.0"] = Color3.fromRGB(0, 200, 150),
	["Старейшина"] = Color3.fromRGB(0, 170, 255),
	["Маэстро"] = Color3.fromRGB(180, 0, 255),
	["Герой сервера"] = Color3.fromRGB(255, 85, 0),
	["Призрак Лавы"] = Color3.fromRGB(255, 0, 127),
	["Душа карты"] = Color3.fromRGB(255, 230, 0), -- золотистый
	["БОГ сервера 🔥"] = Color3.fromRGB(255, 0, 255) -- фиолетовый / магента
}


local function getRank(minutes)
	for _, rank in ipairs(RANKS) do
		if minutes >= rank.Minutes then
			return rank.Name
		end
	end
	return "Без ранга"
end

local function createBillboard(player, rankName)
	local character = player.Character
	if not (character and character:FindFirstChild("Head")) then return end

	local old = character:FindFirstChild("PlayerRankBillboard")
	if old then old:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerRankBillboard"
	billboard.Parent = character
	billboard.Adornee = character.Head
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Size = UDim2.new(0, 200, 0, 30)
	billboard.AlwaysOnTop = true

	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = billboard
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = rankName
	textLabel.TextColor3 = RANK_COLORS[rankName] or Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextScaled = false
	textLabel.TextSize = 16
	textLabel.RichText = false
	textLabel.TextWrapped = true
end

local function loadPlayerData(player)
	local success, data = pcall(function()
		return timeStore:GetAsync(player.UserId)
	end)

	if success then
		return data or 0
	else
		warn("Не удалось загрузить данные для игрока:", player.Name)
		return 0
	end
end

local function savePlayerData(player, minutes)
	local success, errorMessage = pcall(function()
		timeStore:SetAsync(player.UserId, minutes)
	end)

	if not success then
		warn("Ошибка сохранения данных для игрока:", player.Name, errorMessage)
	end
end

Players.PlayerAdded:Connect(function(player)
	local totalMinutes = loadPlayerData(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local timePlayed = Instance.new("IntValue")
	timePlayed.Name = "MinutesPlayed"
	timePlayed.Value = totalMinutes
	timePlayed.Parent = leaderstats

	local rank = Instance.new("StringValue")
	rank.Name = "Rank"
	rank.Value = getRank(totalMinutes)
	rank.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		task.wait(1)
		createBillboard(player, rank.Value)
	end)

	while player.Parent do
		task.wait(60)
		totalMinutes += 1
		timePlayed.Value = totalMinutes

		local newRank = getRank(totalMinutes)
		if newRank ~= rank.Value then
			rank.Value = newRank
			createBillboard(player, newRank)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local minutes = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("MinutesPlayed")
	if minutes then
		savePlayerData(player, minutes.Value)
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Создаём DebugAddTime если его ещё нет
local remote = ReplicatedStorage:FindFirstChild("DebugAddTime")
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "DebugAddTime"
	remote.Parent = ReplicatedStorage
end

remote.OnServerEvent:Connect(function(player, addedMinutes)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end

	local timePlayed = stats:FindFirstChild("MinutesPlayed")
	local rank = stats:FindFirstChild("Rank")

	if timePlayed and rank then
		timePlayed.Value += addedMinutes
		local newRank = getRank(timePlayed.Value)
		if newRank ~= rank.Value then
			rank.Value = newRank
			createBillboard(player, newRank)
		end
	end
end)

