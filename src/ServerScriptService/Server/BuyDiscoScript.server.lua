local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local discoEvent = ReplicatedStorage:WaitForChild("StartDiscoEvent")

-- Вставь ID своего геймпасса
local gamepassId = 1288640714

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassId, wasPurchased)
	if wasPurchased and purchasedPassId == gamepassId then
		print(player.Name .. " купил геймпасс! Запуск дискотеки!")

		-- Сообщаем всем клиентам имя покупателя
		discoEvent:FireAllClients(player.Name)
	end
end)
