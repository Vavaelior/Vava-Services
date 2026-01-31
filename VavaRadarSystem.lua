--[[ ESX = exports['es_extended']:getSharedObject() ]]
local finePerKmh = 17 -- Amende par km/h au-dessus de la limite
local isProcessingRadar = false -- Pour éviter les doubles détections

-- Création des blips pour les radars
Citizen.CreateThread(function()
    for _, radar in ipairs(config.radarPoints) do
        local blip = AddBlipForCoord(radar.position.x, radar.position.y, radar.position.z)
        SetBlipSprite(blip, 184)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.4)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Radar")
        EndTextCommandSetBlipName(blip)
    end
end)

local isDetectionRunning = false;
local currentVehicle = nil;
local isProcessingBill = false;

local function checkForARadar(playerPosition, speed, index)
    local radarConfig <const> = config.radarPoints[index];
    if (not radarConfig) then return false; end
    local radarPos <const> = radarConfig.position or vector4(0.0, 0.0, 0.0, 0.0);
    local distance <const> = #(vector3(radarPos) - playerPosition);
    if (distance > config.maxDistance) then return false; end

    return speed <= radarConfig.speedlimit and false or true;
end

local function playEffect()
    StartScreenEffect("FocusOut", 0, false);
    PlaySoundFrontend(-1, "Camera_Shoot", "Phone_SoundSet_Default", 1);
    Wait(300);
    StopScreenEffect("FocusOut");
end

local function runRadarDetection()
    local player = PlayerPedId(); -- Plus nécessaire de le mettre à jour chaque tick sutie à une mise à jour récente
    local vehicleId = GetVehiclePedIsIn(player, false);
    currentVehicle = vehicleId; --- Pour vérifier que le joueur est toujours dans le même véhicule
    local seatIndex = GetPedInVehicleSeat(vehicleId, -1);
    if (seatIndex ~= player) then return; end

    isDetectionRunning = true;
    while (isDetectionRunning and (vehicleId ~= 0 and vehicleId == currentVehicle))  do
        vehicleId = GetVehiclePedIsIn(player, false);
        local playerPosition <const> = GetEntityCoords(player);
        if (isProcessingBill) then goto continue; end

        for k, v in ipairs(config.radarPoints) do
            local speed <const> = math.floor(msToKmh(GetEntitySpeed(vehicleId)));
            if not checkForARadar(playerPosition, speed, k) then goto nextRadar; end

            ESX.ShowNotification(('~r~RADAR: ~s~Flashé à ~r~%.1f km/h'):format(speed));
            playEffect();

            isProcessingBill = true;
            TriggerServerEvent('radar:payFine', speed, k); --- Envoi de la vitesse au serveur pour le calcul de l'amende, histoire de rendre la triche plus difficile :)

            ::nextRadar::
        end
        ::continue::
        Wait(50);
    end
    
    isDetectionRunning = false;
end

RegisterNetEvent('radar:updateBillState', function()
    if GetInvokingResource() ~= nil then return; end --- Permet d'éviter les appels non autorisés
    Wait(config.delay);
    isProcessingBill = false;
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if (name ~= 'CEventNetworkPlayerEnteredVehicle') then return end

    local playerEntered <const> = GetPlayerPed(args[1]);
    local player <const> = PlayerPedId();
    local vehicle <const> = args[2];
    if ((playerEntered ~= player) or (vehicle == currentVehicle)) then return; end
    
    runRadarDetection(); --- Inutile de faire un thread ici, car AddEventHandler le fait déjà
end)
