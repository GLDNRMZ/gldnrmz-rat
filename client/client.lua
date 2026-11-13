-- Qbox / QBCore / ESX, any target, inventory, notify and progress bar through community_bridge
local Target = exports.community_bridge:Target()
local Inventory = exports.community_bridge:Inventory()
local Notify = exports.community_bridge:Notify()
local ProgressBar = exports.community_bridge:ProgressBar()

local startboss = nil

local function notify(message, notifyType)
    Notify.SendNotify(message, notifyType or 'info', 5000)
end

local function progress(label, duration, dict, clip, flag)
    return ProgressBar.Open({
        duration = duration,
        label = label,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = dict, clip = clip, flag = flag },
    })
end

local function hasNeedItem()
    if not Config.NeedItem or Config.NeedItem == '' then return true end
    local ok, has = pcall(Inventory.HasItem, Config.NeedItem, 1)
    return ok and has == true
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

function StartJobPed()
    if DoesEntityExist(startboss) then return end

    local coords = Config.StartCoordsList[math.random(#Config.StartCoordsList)]
    local selectedModel = Config.StartModels[math.random(#Config.StartModels)]

    RequestModel(selectedModel)
    while not HasModelLoaded(selectedModel) do
        Wait(0)
    end

    startboss = CreatePed(0, selectedModel, coords.xyz, coords.w or 0.0, false, false)

    SetEntityAsMissionEntity(startboss)
    SetPedFleeAttributes(startboss, 0, 0)
    SetBlockingOfNonTemporaryEvents(startboss, true)
    SetEntityInvincible(startboss, true)
    FreezeEntityPosition(startboss, false)

    loadAnimDict("amb@world_human_leaning@female@wall@back@holding_elbow@idle_a")
    TaskPlayAnim(startboss, "amb@world_human_leaning@female@wall@back@holding_elbow@idle_a", "idle_a", 8.0, -1, -1, 1, 0, 0, 0, 0)

    if not IsPedDeadOrDying(startboss, true) then
        Target.AddLocalEntity(startboss, {
            {
                name = 'gldnrmz_rat_talk',
                icon = "fas fa-circle",
                label = "Talk to Stranger",
                distance = 2.0,
                -- Always shown; tell the player what's missing instead of hiding the option
                onSelect = function()
                    if not hasNeedItem() then
                        return notify(('You need a %s to talk to them'):format(Config.NeedItem), 'error')
                    end
                    TriggerEvent('GLDNRMZ-rat:client:menu')
                end,
            },
        })
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        StartJobPed()
    end
end)

AddEventHandler('community_bridge:Client:OnPlayerLoaded', function()
    StartJobPed()
end)

-- The server counts police on duty, then opens the dialog
RegisterNetEvent('GLDNRMZ-rat:client:menu', function()
    TriggerServerEvent('GLDNRMZ-rat:server:requestTalk')
end)

RegisterNetEvent('GLDNRMZ-rat:client:openDialog', function(allowed)
    if not allowed then
        return notify("Not enough police on duty", 'error')
    end
    exports.bl_dialog:showDialog({
        ped = startboss,
        dialog = Config.RatDialog
    })
end)

RegisterNetEvent('GLDNRMZ-rat:client:start', function()
    PoliceAlert()

    pcall(Target.RemoveLocalEntity, startboss)

    TaskStartScenarioInPlace(startboss, "WORLD_HUMAN_STAND_MOBILE_CLUBHOUSE", 0, true)

    if not progress("Arguing with stranger", Config.ProgressArgue, "anim@amb@casino@brawl@fights@argue@", "arguement_loop_mp_m_brawler_01", 16) then
        ClearPedTasksImmediately(startboss)
        return notify(Lang:t("error.canceled"), 'error')
    end

    TriggerServerEvent('GLDNRMZ-rat:server:startr')

    -- Make ped vulnerable before fleeing
    SetEntityInvincible(startboss, false)

    notify("SOMBODY HELP!!")
    ClearPedTasksImmediately(startboss)
    TaskReactAndFleePed(startboss, PlayerPedId())

    SetTimeout(60000, function()
        if DoesEntityExist(startboss) then
            DeleteEntity(startboss)
        end
        -- Respawn ped after 3 minutes
        SetTimeout(180000, function()
            StartJobPed()
        end)
    end)
end)

function PoliceAlert()
    if not Config.Dispatch.Enabled then return end
    if math.random(1,100) >= Config.AlertChance then return end
    local coords = GetEntityCoords(PlayerPedId())
    Config.Dispatch.Function(coords)
end

function TargetDeadPed()
    if DoesEntityExist(startboss) and IsPedDeadOrDying(startboss, true) and Config.SearchBody then
        Target.AddLocalEntity(startboss, {
            {
                name = 'gldnrmz_rat_search',
                icon = "fas fa-skull",
                label = "Investigate Dead Body",
                distance = 1.5,
                onSelect = function() TriggerEvent('GLDNRMZ-rat:client:deadInteraction') end,
            },
        })
    end
end

RegisterNetEvent('GLDNRMZ-rat:client:deadInteraction', function()
    if not Config.SearchBody then return end

    if progress("Searching the body...", Config.ProgressLoot, "amb@medic@standing@kneel@base", "base", 49) then
        TriggerServerEvent('GLDNRMZ-rat:server:giveRewardFromDead')
        pcall(Target.RemoveLocalEntity, startboss)
    else
        notify("Search cancelled", "error")
    end
    ClearPedTasksImmediately(PlayerPedId())
end)

CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        if DoesEntityExist(startboss) and IsPedDeadOrDying(startboss, true) then
            TargetDeadPed()
            break -- Stop checking once the ped is dead
        end
    end
end)
