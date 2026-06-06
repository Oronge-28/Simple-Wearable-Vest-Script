local Framework = nil
local ESX = nil
local QBCore = nil

-- Init Framework
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    
    if GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
        QBCore = exports['qb-core']:getCoreObject()
    else
        Framework = 'standalone'
    end
end)

-- Helper: Show Notification
local function showNotification(msg, type)
    Config.ShowNotification(msg, type)
end

-- Client notification event from server
RegisterNetEvent('radiant_vests:client:showNotification', function(msg, type, title)
    Config.ShowNotification(msg, type, title)
end)

-- Event: Try to use a vest
RegisterNetEvent('radiant_vests:tryUseVest', function(itemName)
    local playerPed = PlayerPedId()
    local currentArmor = GetPedArmour(playerPed)
    local vestConfig = Config.Vests[itemName]

    if not vestConfig then return end

    -- Check conditions before proceeding
    if itemName == 'nobproof' then
        -- Check if player is wearing a visual vest component (Component 9 > 0) or has armor
        local currentVestProp = GetPedDrawableVariation(playerPed, 9)
        if currentVestProp == 0 and currentArmor == 0 then
            showNotification(t('no_armor_to_remove'), 'error')
            return
        end
    else
        -- Check if current armor is already higher or equal to the vest armor
        if currentArmor >= vestConfig.armor then
            showNotification(t('already_max_armor'), 'error')
            return
        end
    end

    local labelText = (itemName == 'nobproof') and t('taking_off') or t('putting_on')
    
    -- ox_lib Progress Bar (handles animation, key disabling, cancel logic and thread yielding automatically)
    local completed = lib.progressBar({
        duration = Config.AnimDuration,
        label = labelText,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = Config.AnimDict,
            clip = Config.AnimName,
            flag = 49
        }
    })

    if completed then
        -- Report success to server to process item deduction and validation
        TriggerServerEvent('radiant_vests:applyVest', itemName)
    else
        showNotification(t('action_cancelled'), 'error')
    end
end)

-- Event: Complete vest (called by server after inventory confirmation)
RegisterNetEvent('radiant_vests:completeVest', function(itemName)
    local playerPed = PlayerPedId()
    local vestConfig = Config.Vests[itemName]

    if not vestConfig then return end

    -- 1. Apply visual vest model (Component 9)
    local model = GetEntityModel(playerPed)
    local prop = nil

    if model == GetHashKey("mp_m_freemode_01") then
        prop = vestConfig.maleProp
    elseif model == GetHashKey("mp_f_freemode_01") then
        prop = vestConfig.femaleProp
    else
        -- Fallback to male prop if custom ped is used
        prop = vestConfig.maleProp
    end

    if prop then
        SetPedComponentVariation(playerPed, 9, prop.drawable, prop.texture, 2)
    end

    -- 2. Apply armor percentage value
    SetPedArmour(playerPed, vestConfig.armor)

    -- 3. Show Success notification
    local successText = (itemName == 'nobproof') and t('finished_taking_off') or t('finished_putting_on')
    showNotification(successText, 'success')
end)
