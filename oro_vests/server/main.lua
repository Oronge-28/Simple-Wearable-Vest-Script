local Framework = nil
local ESX = nil
local QBCore = nil

-- Framework Auto-Detection
Citizen.CreateThread(function()
    -- Wait until database/other scripts are ready
    Citizen.Wait(1000)
    
    if Config.Framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            Framework = 'esx'
            ESX = exports['es_extended']:getSharedObject()
            print('^2[radiant_vests]^7 Auto-detected: ESX Framework')
        elseif GetResourceState('qb-core') == 'started' then
            Framework = 'qb'
            QBCore = exports['qb-core']:getCoreObject()
            print('^2[radiant_vests]^7 Auto-detected: QBCore Framework')
        else
            Framework = 'standalone'
            print('^3[radiant_vests]^7 No framework detected. Usable items will not work automatically. Trigger client events for testing.')
        end
    else
        Framework = Config.Framework
        if Framework == 'esx' then
            ESX = exports['es_extended']:getSharedObject()
        elseif Framework == 'qb' then
            QBCore = exports['qb-core']:getCoreObject()
        end
    end

    -- Register Items after framework detection
    RegisterUsableItems()
end)

-- Function to register usable items in ESX/QBCore
function RegisterUsableItems()
    local items = { 'bulletproof', 'bulletproof2', 'bulletproofpolice', 'nobproof' }

    if Framework == 'esx' then
        for _, itemName in ipairs(items) do
            ESX.RegisterUsableItem(itemName, function(source)
                local src = source
                TriggerClientEvent('radiant_vests:tryUseVest', src, itemName)
            end)
        end
    elseif Framework == 'qb' then
        for _, itemName in ipairs(items) do
            QBCore.Functions.CreateUseableItem(itemName, function(source, item)
                local src = source
                TriggerClientEvent('radiant_vests:tryUseVest', src, itemName)
            end)
        end
    end
end

-- Helper: Get Player Item count
local function hasItem(playerId, itemName)
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local item = xPlayer.getInventoryItem(itemName)
            return item and item.count > 0 or false
        end
    elseif Framework == 'qb' then
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        if xPlayer then
            local item = xPlayer.Functions.GetItemByName(itemName)
            return item and item.amount > 0 or false
        end
    else
        return true -- Mockup for testing standalone
    end
    return false
end

-- Helper: Remove Item
local function removeItem(playerId, itemName)
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.removeInventoryItem(itemName, 1)
            return true
        end
    elseif Framework == 'qb' then
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        if xPlayer then
            xPlayer.Functions.RemoveItem(itemName, 1)
            -- Trigger inventory update client event for qb-inventory
            TriggerClientEvent('inventory:client:ItemBox', playerId, QBCore.Shared.Items[itemName], 'remove')
            return true
        end
    end
    return false
end

-- Helper: Add Item
local function addItem(playerId, itemName)
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.addInventoryItem(itemName, 1)
            return true
        end
    elseif Framework == 'qb' then
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
        if xPlayer then
            xPlayer.Functions.AddItem(itemName, 1)
            TriggerClientEvent('inventory:client:ItemBox', playerId, QBCore.Shared.Items[itemName], 'add')
            return true
        end
    end
    return false
end

-- Helper: Show Notification
local function notifyPlayer(playerId, msg, type, title)
    TriggerClientEvent('radiant_vests:client:showNotification', playerId, msg, type or 'info', title or 'Schutzwesten')
end

-- Server Event: Triggered when progress bar completes on Client
RegisterNetEvent('radiant_vests:applyVest', function(itemName)
    local src = source
    local vestConfig = Config.Vests[itemName]

    if not vestConfig then return end

    -- Verify player actually has the item
    if not hasItem(src, itemName) then
        notifyPlayer(src, 'Du besitzt diesen Gegenstand nicht!', 'error')
        return
    end

    -- Process inventory change
    local removed = true
    if vestConfig.remove then
        removed = removeItem(src, itemName)
    end

    if removed then
        -- If putting on a vest, give them the "nobproof" item so they can take it off later
        if vestConfig.giveNobproof then
            addItem(src, 'nobproof')
        end

        -- Trigger client to apply actual armor and ped components
        TriggerClientEvent('radiant_vests:completeVest', src, itemName)
    else
        notifyPlayer(src, 'Fehler beim Verwenden des Gegenstands.', 'error')
    end
end)
