-- [[ QBCore ]] --
local QBCore = exports['qb-core']:GetCoreObject()

-- [[ Config ]] --
Config = Config or {}

Config.QBCoreSettings = {
    ['Fuel'] = 'cdn-fuel', -- Fuel Resource Name
    ['Renewed-Banking'] = true, -- If Bank is true it will generate transactions
}

Config.ResourceSettings = {
    ['Job'] = {
        ['Required'] = false,
        ['JobName'] = 'electrician',
        ['ProgressTime'] = math.random(2500, 5000), -- In MS
    },
    ['JobLocation'] = {
        ['Ped'] = {
            ['Coords'] = vector4(738.8, 136.18, 80.73, 242.49),
            ['Model'] = 'S_M_Y_Construct_02',
            -- [[ https://wiki.rage.mp/index.php?title=Peds ]]
        },
        ['Blip'] = {
            ['ID'] = 539,
            ['Color'] = 3,
            -- [[ ^ https://docs.fivem.net/docs/game-references/blips/ + https://docs.fivem.net/docs/game-references/blips/#blip-colors ]]
            ['Scale'] = 0.8, -- Default QBCore size
            ['Text'] = "San Andreas Water & Power",
        },
        ['SpawnLocation'] = vector4(744.07, 127.84, 79.62, 237.07),
    },
    ['Payment'] = {
        ['Type'] = 'bank', -- 'bank' or 'cash'
    },
}

Config.Locations = {
    [1] = {
        Coords = { -- Coords should aways be v4
            -- [[ Mirror Park ]] --
            vector4(1252.61, -350.7, 69.36, 165.95),
            vector4(1242.3, -423.78, 68.9, 76.65),
            vector4(1241.51, -426.57, 68.9, 80.41),
            vector4(1152.38, -433.18, 67.01, 257.78),
            vector4(1108.48, -340.54, 67.18, 211.98),
            vector4(1103.21, -344.22, 67.18, 213.46),
            vector4(1092.31, -341.94, 67.23, 215.66),
            vector4(1229.9, -567.91, 69.25, 271.54),
            -- [[ Golf Course ]] --
            vector4(-1355.75, 117.86, 56.25, 185.88),
            -- [[ Rockford ]] --
        },
        Payment = math.random(1000, 2000), -- Recommanded to keep random
    },
    [2] = {
        Coords = {
            -- [[ Movie Studio ]] --
            vector4(-1178.74, -591.75, 27.34, 307.62),
            vector4(-1186.5, -584.32, 27.43, 307.46),
            vector4(-1163.22, -605.06, 26.85, 309.27),
            vector4(-1164.65, -603.32, 26.85, 307.86),
            vector4(-1162.61, -599.08, 27.31, 41.24),
            vector4(-1225.41, -555.37, 27.79, 309.12),
            vector4(-1236.33, -536.7, 29.77, 309.43),
            vector4(-1238.05, -534.05, 29.27, 311.16),
            vector4(-1261.82, -514.29, 31.66, 314.08),
            vector4(-1162.57, -572.5, 29.11, 130.7),
            vector4(-1138.23, -586.15, 29.61, 301.33),
            vector4(-1072.92, -500.44, 35.51, 115.5),
            vector4(-1091.5, -507.23, 35.83, 207.39),
            vector4(-1110.17, -476.04, 35.18, 113.37),
            vector4(-1113.76, -470.07, 35.13, 119.59),
            vector4(-1140.31, -436.57, 34.46, 106.36),
            vector4(-1103.19, -433.28, 35.42, 30.53),
        },
        Payment = math.random(5000, 7500)
    }
}

function Config.PerformHack()
    local Success = exports['SN-Hacking']:Thermite(7, 5, 10000, 2, 2, 3000) --Thermite(boxes(number), correctboxes(number), time(milliseconds), lifes(number), rounds(number), showTime(milliseconds))

    if Success then
        QBCore.Functions.Progressbar('fixing_lent_box', 'Fixing Electrical Box', Config.ResourceSettings['Job']['ProgressTime'], false, true, { -- Name | Label | Time | useWhileDead | canCancel
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Play When Done
            ExecuteCommand('e c')
            TriggerEvent('LENT-Electrical:Client:SendJob')
            exports['LENT-Library']:SendNotification('You fixed this box!', 'success')
        end, function() -- Play When Cancel
            ExecuteCommand('e c')
            exports['LENT-Library']:SendNotification('You cancelled the progress', 'error')
        end)
    end
end