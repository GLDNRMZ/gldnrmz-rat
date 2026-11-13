-- Qbox / QBCore / ESX through community_bridge
local Framework = exports.community_bridge:Framework()
local Inventory = exports.community_bridge:Inventory()
local Notify = exports.community_bridge:Notify()

-- A body can only be searched by a player who actually started the job
local canSearch = {}

local function policeOnDuty()
    local count = 0
    for _, job in ipairs(Config.PoliceJobs) do
        local ok, players = pcall(Framework.GetPlayersByJob, job)
        if ok and type(players) == 'table' then count = count + #players end
    end
    return count
end

RegisterNetEvent('GLDNRMZ-rat:server:requestTalk', function()
    local src = source
    TriggerClientEvent('GLDNRMZ-rat:client:openDialog', src, policeOnDuty() >= Config.MinimumMethJobPolice)
end)

RegisterNetEvent('GLDNRMZ-rat:server:startr', function()
    local src = source

    if Config.NeedItem and Config.NeedItem ~= '' and not Inventory.HasItem(src, Config.NeedItem, 1) then return end

    -- Randomly select an item and amount from the configuration list
    local randomItem = Config.GiveItems[math.random(#Config.GiveItems)]
    local amountToGive = math.random(1, randomItem.maxAmount)

    if Config.NeedCash then
        local balance = tonumber(Framework.GetAccountBalance(src, 'money')) or 0
        if balance < Config.RunCost then
            return Notify.SendNotify(src, Lang:t("error.you_dont_have_enough_money"), 'error', 5000)
        end
        Framework.RemoveAccountBalance(src, 'money', Config.RunCost)
    end

    if Config.RemoveItem and not Inventory.RemoveItem(src, Config.NeedItem, 1) then return end

    Inventory.AddItem(src, randomItem.item, amountToGive)
    canSearch[src] = true
end)

RegisterNetEvent('GLDNRMZ-rat:server:giveRewardFromDead', function()
    local src = source
    if not canSearch[src] then return end
    canSearch[src] = nil

    for _, itemData in ipairs(Config.RewardItems) do
        if math.random(1, 100) <= itemData.chance then
            local amount = math.random(itemData.minAmount, itemData.maxAmount)
            Inventory.AddItem(src, itemData.item, amount)
        end
    end
end)

AddEventHandler('playerDropped', function()
    canSearch[source] = nil
end)
