local Framework = nil
local QBCore = nil
local ESX = nil

local claimLocks = {}
local openLocks = {}

AddEventHandler('playerDropped', function()
    local src = source
    claimLocks[src] = nil
    openLocks[src] = nil
end)

CreateThread(function()
    if GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        QBCore = exports['qb-core']:GetCoreObject()

    elseif GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()

    elseif GetResourceState('qbx_core') == 'started' then
        Framework = 'qbox'

    else
        Framework = 'standalone'
    end
end)

RegisterNetEvent('777-starterbox:server:claim', function()
    local src = source

    if claimLocks[src] then return end
    claimLocks[src] = true

    local identifier = GetPlayerIdentifier(src)

    if not identifier then
        claimLocks[src] = nil
        return
    end

    if Config.UseSQL then
        local exists = MySQL.scalar.await(
            'SELECT identifier FROM starterbox_claimed WHERE identifier = ?',
            {identifier}
        )

        if exists then
            TriggerClientEvent('777-starterbox:notify', src, "Already claimed!", "error")
            claimLocks[src] = nil
            return
        end

        MySQL.insert.await(
            'INSERT INTO starterbox_claimed (identifier) VALUES (?)',
            {identifier}
        )
    end

    GiveItem(src, "starterbox", 1)

    TriggerClientEvent('777-starterbox:notify', src, "You received a Starter Box!", "success")

    claimLocks[src] = nil
end)

RegisterNetEvent('777-starterbox:server:openBox', function()
    local src = source

    if openLocks[src] then return end
    openLocks[src] = true

    if GetItemCount(src, "starterbox") < 1 then
        TriggerClientEvent('777-starterbox:notify', src, "You don't have a Starter Box!", "error")
        openLocks[src] = nil
        return
    end

    local removed = RemoveItem(src, "starterbox", 1)
    if not removed then
        TriggerClientEvent('777-starterbox:notify', src, "Failed to open Starter Box!", "error")
        openLocks[src] = nil
        return
    end

    for _, v in pairs(Config.StarterItems) do
        GiveItem(src, v.item, v.amount)
    end

    SendDiscordLog(src)

    TriggerClientEvent('777-starterbox:notify', src, "Starter box opened!", "success")

    openLocks[src] = nil
end)

function GetItemCount(src, item)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:GetItemCount(src, item) or 0
    end

    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local qItem = Player.Functions.GetItemByName(item)
            return qItem and qItem.amount or 0
        end
        return 0
    end

    if Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local eItem = xPlayer.getInventoryItem(item)
            return eItem and eItem.count or 0
        end
        return 0
    end

    return 0
end

function GiveItem(src, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:AddItem(src, item, amount)
        return
    end

    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddItem(item, amount)
        end
        return
    end

    if Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addInventoryItem(item, amount)
        end
        return
    end
end

function RemoveItem(src, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        local success = exports.ox_inventory:RemoveItem(src, item, amount)
        return success and true or false
    end

    if Framework == 'qb' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.Functions.RemoveItem(item, amount) and true or false
        end
        return false
    end

    if Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.removeInventoryItem(item, amount)
            return true
        end
        return false
    end

    return false
end

function SendDiscordLog(src)
    if Config.DiscordWebhook == "" then return end

    local name = GetPlayerName(src)
    local identifier = GetPlayerIdentifier(src)

    local embed = {{
        title = "🎁 Starter Box Opened",
        color = 65280,
        description = "**Player:** "..name.."\n**Identifier:** "..identifier,
        footer = { text = "777 Scripts" }
    }}

    PerformHttpRequest(
        Config.DiscordWebhook,
        function() end,
        'POST',
        json.encode({
            username = "Starter Logs",
            embeds = embed
        }),
        { ['Content-Type'] = 'application/json' }
    )
end