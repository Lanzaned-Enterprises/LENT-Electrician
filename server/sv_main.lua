-- [[ QBCore ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Variables ]] --
local Jobs = {}
local NewPayment
-- [[ Resource Metadata ]] --


-- [[ Events ]] --
RegisterServerEvent('LENT-Electrician:Server:CreateJob', function()
    local src = source
    if Config.ResourceSettings['Job']['Required'] then
        if Player.PlayerData.job.name == Config.ResourceSettings['Job']['JobName'] then
            TriggerEvent('LENT-Electrician:Server:StartJob', src)
        else
            exports['LENT-Library']:ServerNotification('You are not employed as Electrician', 'error')
        end
    else
        TriggerEvent('LENT-Electrician:Server:StartJob', src)
    end
end)

RegisterNetEvent('LENT-Electrician:Server:StartJob', function(source)
    local src = source
    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] = {
        ['BoxLocation'] = vector4(0, 0, 0, 0),
        ['ElectricianJobTruckId'] = 0,
        ['Payment'] = 0,
    }

    local coords, payment = GetLocationInfo()

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['BoxLocation'] = coords
    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['Payment'] = payment

    TriggerClientEvent('LENT-Electrician:Client:CreateJob', src)
end)

RegisterNetEvent('LENT-Electrician:Server:NewJob', function(source)
    local src = source

    local coords, payment = GetLocationInfo()

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['BoxLocation'] = coords
    NewPayment = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['Payment'] + payment

    local BlipCoords = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['BoxLocation']
    local PlayerCitizenId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    TriggerClientEvent('LENT-Electrician:Client:AddBoxTarget', src, PlayerCitizenId, BlipCoords)

    TriggerClientEvent('LENT-Electrician:Client:DrawWaypoint', src, BlipCoords)
end)

RegisterNetEvent('LENT-Electrician:Server:CancelJob', function()
    local src = source
    if Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] == nil then return end

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] = nil

    TriggerClientEvent('LENT-Electrician:Client:ClearAll', src)

    TriggerClientEvent('LENT-Electrician:Client:ClearVehcile', src)
end)

RegisterNetEvent('LENT-Electrician:Server:GiveVehicleKeys', function(Plate, Network)
    local src = source

    Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['ElectricianJobTruckId'] = Network
    local BlipCoords = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['BoxLocation']
    local PlayerCitizenId = QBCore.Functions.GetPlayer(src).PlayerData.citizenid

    TriggerClientEvent('vehiclekeys:client:SetOwner', src, Plate)
    TriggerClientEvent('LENT-Electrician:Client:AddBoxTarget', src, PlayerCitizenId, BlipCoords)
    TriggerClientEvent('LENT-Electrician:Client:DrawWaypoint', src, BlipCoords)
end)

RegisterNetEvent('LENT-Electrician:Server:ReturnVehicle', function(JobsDone)
    local src = source
    if Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] == nil then return end

    TriggerClientEvent('LENT-Electrician:Client:ClearAll', src)

    TriggerClientEvent('LENT-Electrician:Client:RemoveZoneSync', -1)
    TriggerClientEvent('LENT-Electrician:Client:ClearVehcile', src)
    TriggerEvent('LENT-Electrician:Server:GetPayment', src, JobsDone)
end)

RegisterNetEvent('LENT-Electrician:Server:GetPayment', function(source, JobsDone)
    local src = source
    if Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] ~= nil then
        JobsDone = tonumber(JobsDone)

        if JobsDone > 0 then
            local bonus = 0
            local pay = Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid]['Payment']

            if JobsDone > 5 then
                bonus = math.ceil((pay / 10) * 5)
            elseif JobsDone > 10 then
                bonus = math.ceil((pay / 10) * 7)
            elseif JobsDone > 15 then
                bonus = math.ceil((pay / 10) * 10)
            elseif JobsDone > 20 then
                bonus = math.ceil((pay / 10) * 12)
            end

            local check = bonus + pay

            local Player = QBCore.Functions.GetPlayer(src)
            if Config.ResourceSettings['Payment']['Type'] == 'bank' then
                if Config.QBCoreSettings['Renewed-Banking'] then
                    local cid = Player.PlayerData.citizenid
                    local title = 'San Andreas Power & Water - Salary'
                    local name = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
                    local txt = 'Received Pay for working for SADWP'
                    local issuer = 'Stevan Powel @ San Andreas Department of Water & Power'
                    -- [[ ^ Reference to: Steven Powell CEO of Southern California Edison ]]
                    local reciver = name
                    local type = 'deposit'
                    exports['Renewed-Banking']:handleTransaction(cid, title, check, txt, issuer, reciver, type)
                end

                Player.Functions.AddMoney('bank', check, 'Electrician Job')
            else
                Player.Functions.AddMoney('cash', check, 'Electrician Job')
            end
        end
        Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] = nil
    end
end)

RegisterNetEvent('LENT-Electrician:Server:FixElectricalBox', function()
    local src = source
    if Jobs[QBCore.Functions.GetPlayer(src).PlayerData.citizenid] == nil then return end

    TriggerClientEvent('LENT-Electrician:Client:CanReturn', src)

    TriggerEvent('LENT-Electrician:Server:NewJob', src)
    TriggerClientEvent('LENT-Electrician:Client:GetPlaySlip', src)
end)

-- [[ Functions ]] --
function GetLocationInfo()
    local data = Config.Locations[math.random(#Config.Locations)]
    local coords = data.Coords[math.random(#data.Coords)]

    local payment = data.Payment

    return coords, payment
end

-- [[ Threads ]] --


-- [[ Other ]] --
