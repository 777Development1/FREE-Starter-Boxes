local ped = nil
local openingBox = false 
local activeBox = nil    
local claimingBox = false 

CreateThread(function()
    local model = joaat(Config.Ped.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    ped = CreatePed(0, model,
        Config.Ped.coords.x,
        Config.Ped.coords.y,
        Config.Ped.coords.z - 1,
        Config.Ped.coords.w,
        false, true
    )

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if Config.UseTarget and GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(ped, {
            {
                label = "Get Starter Box",
                icon = "fas fa-box",
                onSelect = function()
                    ClaimBox()
                end
            }
        })
    else
        CreateThread(function()
            while true do
                local sleep = 1000
                local coords = GetEntityCoords(PlayerPedId())
                local dist = #(coords - vec3(
                    Config.Ped.coords.x,
                    Config.Ped.coords.y,
                    Config.Ped.coords.z
                ))

                if dist < 3.0 then
                    sleep = 0
                    DrawText3D(
                        Config.Ped.coords.x,
                        Config.Ped.coords.y,
                        Config.Ped.coords.z + 1.0,
                        "[E] Get Starter Box"
                    )

                    if IsControlJustPressed(0, 38) then
                        ClaimBox()
                    end
                end

                Wait(sleep)
            end
        end)
    end
end)

RegisterNetEvent('777-starterbox:client:useBox', function()
    OpenStarterBox()
end)

function ClaimBox()
    if claimingBox then return end
    claimingBox = true

    local player = PlayerPedId()

    if Config.ClaimAnim.Enabled and ped and DoesEntityExist(ped) then
        FreezeEntityPosition(player, true)

        local dict = Config.ClaimAnim.Dict
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end

        TaskTurnPedToFaceEntity(player, ped, 500)
        TaskTurnPedToFaceEntity(ped, player, 500)
        Wait(500)

        TaskPlayAnim(player, dict, Config.ClaimAnim.PlayerAnim, 3.0, -3.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(ped, dict, Config.ClaimAnim.PedAnim, 3.0, -3.0, -1, 1, 0, false, false, false)

        Wait(Config.ClaimAnim.Duration)

        ClearPedTasks(player)
        ClearPedTasks(ped)
        FreezeEntityPosition(player, false)
    end

    TriggerServerEvent('777-starterbox:server:claim')

    claimingBox = false
end

function OpenStarterBox()
    if openingBox then return end
    openingBox = true

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local forward = GetEntityForwardVector(player)

    FreezeEntityPosition(player, true)

    local propModel = `prop_cs_cardbox_01`
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do Wait(0) end

    local boxCoords = coords + (forward * 0.8)
    local box = CreateObject(propModel, boxCoords.x, boxCoords.y, boxCoords.z - 1.0, false, false, false)
    activeBox = box

    SetEntityHeading(box, GetEntityHeading(player))

    local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    local anim = "machinic_loop_mechandplayer"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    TaskTurnPedToFaceCoord(player, boxCoords.x, boxCoords.y, boxCoords.z, 500)
    Wait(500)

    TaskPlayAnim(player, dict, anim, 3.0, -3.0, -1, 1, 0, false, false, false)

    local finished = ProgressBar("Opening Starter Box...", Config.OpenTime)

    ClearPedTasks(player)
    DeleteBoxProp()
    SetModelAsNoLongerNeeded(propModel)

    FreezeEntityPosition(player, false)
    openingBox = false

    if finished then
        TriggerServerEvent('777-starterbox:server:openBox')
    else
        Notify("Canceled", "error")
    end
end

function DeleteBoxProp()
    if activeBox and DoesEntityExist(activeBox) then
        Wait(200)
        DeleteEntity(activeBox)
    end
    activeBox = nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    DeleteBoxProp()
    if ped and DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end)

function ProgressBar(label, duration)
    if GetResourceState('ox_lib') == 'started' and lib then
        return lib.progressBar({
            duration = duration,
            label = label,
            canCancel = true,
            disable = { move = true, car = true, combat = true }
        })
    end

    if GetResourceState('qb-core') == 'started' then
        local success, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if success and core then
            local done = nil

            core.Functions.Progressbar(
                "starter_box",
                label,
                duration,
                false,
                true,
                {},
                {},
                {},
                {},
                function() done = true end,
                function() done = false end
            )

            while done == nil do Wait(0) end
            return done
        end
    end

    Wait(duration)
    return true
end

RegisterNetEvent('777-starterbox:notify', function(msg, type)
    Notify(msg, type)
end)

function Notify(msg, type)
    type = type or "inform"

    if GetResourceState('ox_lib') == 'started' and lib then
        lib.notify({ description = msg, type = type })
        return
    end

    if GetResourceState('okokNotify') == 'started' then
        exports['okokNotify']:Alert("Starter Box", msg, 5000, type)
        return
    end

    if GetResourceState('qb-core') == 'started' then
        TriggerEvent('QBCore:Notify', msg, type)
        return
    end

    if GetResourceState('es_extended') == 'started' then
        TriggerEvent('esx:showNotification', msg)
        return
    end

    print("[StarterBox] " .. msg)
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z,0)
    DrawText(0.0,0.0)
    ClearDrawOrigin()
end