-- [[ QBCore ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Variables ]] --
local CurrentlyOnJob = false
local returnVehicle = false

local JobsDone = 0

local boxCoords = vector3(0, 0, 0)

local ElectricVehicle = nil
local ElectricianBlip = nil

-- [[ Resource Metadata ]] --
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)

AddEventHandler('onResourceStop', function(ResourceName)
    if GetCurrentResourceName() == ResourceName then
        RemoveBlip(ElectricianBlip)
    end
end)

-- [[ Events ]] --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('LENT-Electrician:Client:SendNotify', function(text, type, time)
    Notify('cl', text, type, time)
end)

RegisterNetEvent('LENT-Electrician:Client:CreateJob', function()
    local VehicleHash = `burrito`
    QBCore.Functions.LoadModel(VehicleHash)
    local VehicleSpawn = Config.ResourceSettings['JobLocation']['SpawnLocation']
    ElectricVehicle = CreateVehicle(VehicleHash, VehicleSpawn.x, VehicleSpawn.y, VehicleSpawn.z, VehicleSpawn.w, true, true)

    local Plate = GetVehicleNumberPlateText(ElectricVehicle)
    local Network = NetworkGetNetworkIdFromEntity(ElectricVehicle)

    SetEntityAsMissionEntity(ElectricVehicle)
    SetNetworkIdExistsOnAllMachines(ElectricVehicle, true)
    NetworkRegisterEntityAsNetworked(ElectricVehicle)
    SetNetworkIdCanMigrate(Network, true)

    SetVehicleLivery(ElectricVehicle, 3)

    SetVehicleDirtLevel(ElectricVehicle, 0)
    SetVehicleEngineOn(ElectricVehicle, true, true)
    SetVehicleDoorsLocked(ElectricVehicle, 1)

    exports[Config.QBCoreSettings['Fuel']]:SetFuel(ElectricVehicle, 100)

    CurrentlyOnJob = true

    TriggerServerEvent('LENT-Electrician:Server:GiveVehicleKeys', Plate, Network)

    IsOnJob = true
end)

RegisterNetEvent('LENT-Electrician:Client:AddBoxTarget', function(PlayerCitizenId, coords)
    boxCoords = coords

    exports['qb-target']:AddBoxZone(PlayerCitizenId, vector3(boxCoords.x, boxCoords.y, boxCoords.z), 3.5, 2.0, {
        name = PlayerCitizenId,
        heading = boxCoords.w,
        debugPoly = false,
        minZ = boxCoords.z - 1,
        maxZ = boxCoords.z + 1,
        }, {
            options = {
                { -- Repair the box
                    icon = 'fas fa-circle',
                    label = 'Fix Electrical Box',
                    canInteract = function()
                        return not cl_fixed
                    end,
                    action = function()
                        TriggerEvent('LENT-Electrician:Client:FixElectricalBox')
                    end,
                },
            },
        distance = 2.0
    })
end)

RegisterNetEvent('LENT-Electrician:Client:FixElectricalBox', function()
    ExecuteCommand('e weld')

   Config.PerformHack()
end)

RegisterNetEvent('LENT-Electrical:Client:SendJob', function()
    if IsOnJob then
        JobsDone = JobsDone + 1
        Notify("cl", 'You\'ve completed: ' .. JobsDone .. ' box repairs', "success", 2500)
        RemoveBlip(ElectricianBlip)
        Wait(2500)
        TriggerServerEvent('LENT-Electrician:Server:FixElectricalBox')
    else
        return
    end
end)

RegisterNetEvent('LENT-Electrician:Client:GetPaySlip', function()
    if JobsDone > 0 then
        TriggerServerEvent("LENT-Electrician:Server:ReturnVehicle", JobsDone)
        JobsDone = 0
        
    else
        Notify('client', "You haven't done any work yet!", 'error')
    end
end)

RegisterNetEvent('LENT-Electrician:Client:CanReturn', function()
    returnVehicle = true
end)

RegisterNetEvent('LENT-Electrician:Client:ClearAll', function()
    CurrentlyOnJob = false
    boxCoords = vector3(0, 0, 0)
    returnVehicle = false
    RemoveBlip(ElectricianBlip)
end)

RegisterNetEvent('LENT-Electrician:Client:ClearVehcile', function()
    if DoesEntityExist(ElectricVehicle) then
        NetworkRequestControlOfEntity(ElectricVehicle)
        Wait(500)
        DeleteEntity(ElectricVehicle)
        ElectricVehicle = nil
    end
end)

RegisterNetEvent('LENT-Electrician:Client:RemoveZoneSync', function(PlayerCitizenId)
    exports['qb-target']:RemoveZone(PlayerCitizenId)
end)

RegisterNetEvent('LENT-Electrician:Client:DrawWaypoint', function(coords)
    ElectricianBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(ElectricianBlip, 8)
    SetBlipScale(ElectricianBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Fix Electrical Box')
    EndTextCommandSetBlipName(ElectricianBlip)
    SetBlipColour(ElectricianBlip, 5)
    SetBlipRoute(ElectricianBlip, true)
    SetBlipRouteColour(ElectricianBlip, 5)
end)

RegisterNetEvent('LENT-Electrician:Client:SendPhone', function(event, Sender, Subject, Message)
    if event == 'email' then
        SendPhoneEmail(Sender, Subject, Message)
    end
end)

-- [[ Functions ]] --
function SendPhoneEmail(Sender, Subject, Message)
    local C = Config.QBCoreSettings['Phone']
    if C == 'qb' then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = Sender,
            subject = Subject,
            message = Message,
        })
    elseif C == 'gks' then
        local MailData = {
            sender = Sender,
            image = '/html/static/img/icons/mail.png',
            subject = Subject,
            message = Message
          }
          exports["gksphone"]:SendNewMail(MailData)
    elseif C == 'qs' then
        TriggerServerEvent('qs-smartphone:server:sendNewMail', {
            sender = Sender,
            subject = Subject,
            message = Message,
        })
    elseif C == 'npwd' then
        exports["npwd"]:createNotification({
            notisId = "LENT:EMAIL",
            appId = "EMAIL",
            content = Message,
            secondaryTitle = Sender,
            keepOpen = false,
            duration = 5000,
            path = "/email",
        })
    end
end

-- [[ Threads ]] --
CreateThread(function()
    local JobBlip = AddBlipForCoord(Config.ResourceSettings['JobLocation']['Ped']['Coords'].x, Config.ResourceSettings['JobLocation']['Ped']['Coords'].y, Config.ResourceSettings['JobLocation']['Ped']['Coords'].z)
    SetBlipSprite(JobBlip, Config.ResourceSettings['JobLocation']['Blip']['ID'])
    SetBlipColour(JobBlip, Config.ResourceSettings['JobLocation']['Blip']['Color'])
    SetBlipScale(JobBlip, Config.ResourceSettings['JobLocation']['Blip']['Scale'])
    SetBlipAsShortRange(JobBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.ResourceSettings['JobLocation']['Blip']['Text'])
    EndTextCommandSetBlipName(JobBlip)

    QBCore.Functions.LoadModel(Config.ResourceSettings['JobLocation']['Ped']['Model'])
    local ElectricPed = CreatePed(0, Config.ResourceSettings['JobLocation']['Ped']['Model'], Config.ResourceSettings['JobLocation']['Ped']['Coords'].x, Config.ResourceSettings['JobLocation']['Ped']['Coords'].y, Config.ResourceSettings['JobLocation']['Ped']['Coords'].z - 1, Config.ResourceSettings['JobLocation']['Ped']['Coords'].w, false, false)
    TaskStartScenarioInPlace(ElectricPed, 'WORLD_HUMAN_CLIPBOARD', true)
    FreezeEntityPosition(ElectricPed, true)
    SetEntityInvincible(ElectricPed, true)
    SetBlockingOfNonTemporaryEvents(ElectricPed, true)

    if Config.ResourceSettings['JobLocation']['Ped']['Model'] == 'S_M_Y_Construct_02' then
        SetPedComponentVariation(ElectricPed, 3, 1, 1, 0)
        SetPedComponentVariation(ElectricPed, 8, 2, 0, 0)
        SetPedComponentVariation(ElectricPed, 10, 1, 0, 0)
        SetPedComponentVariation(ElectricPed, 4, 1, 1, 0)

        SetPedPropIndex(ElectricPed, 0, 0, 2, true)
        SetPedPropIndex(ElectricPed, 1, 0, 0, true)
    end

    exports['qb-target']:AddTargetEntity(ElectricPed, {
        options = {
            { -- Create Jpb
                icon = 'fas fa-circle',
                label = 'Request Job',
                canInteract = function()
                    return not CurrentlyOnJob
                end,
                action = function()
                    TriggerServerEvent('LENT-Electrician:Server:CreateJob')
                end,
            },
            { -- Cancel the current job
                icon = 'fas fa-circle',
                label = 'Cancel Job',
                canInteract = function()
                    return CurrentlyOnJob
                end,
                action = function()
                    TriggerServerEvent('LENT-Electrician:Server:CancelJob')
                    TriggerEvent('LENT-Electrician:Client:GetPaySlip')
                end,
            },
            { -- Returning the vehicle
                icon = 'fas fa-circle',
                label = 'Return Vehicle',
                canInteract = function()
                    return returnVehicle
                end,
                action = function()
                    TriggerEvent('LENT-Electrician:Client:GetPaySlip')
                end,
            }
        },

        distance = 2.0
    })
end)

-- [[ Other ]] --
