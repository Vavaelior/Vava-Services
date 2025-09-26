ESX = exports['es_extended']:getSharedObject()

local speedLimit = 100.0 -- Limite de vitesse en km/h
local finePerKmh = 17 -- Amende par km/h au-dessus de la limite
local isProcessingRadar = false -- Pour éviter les doubles détections

-- Points des radars
local radarPoints = {
    -- Format: {x = coordX, y = coordY, z = coordZ, heading = direction}
    {x = 170.0, y = -779.0, z = 31.0, heading = 315.0},         -- Radar PC
    {x = -2.4, y = -941.0, z = 29.3, heading = 117.0},          -- Radar Chantier
    {x = 1208.0, y = -1402.0, z = 35.2, heading = 90.0},        -- Radar boulevard
    {x = 2506.0, y = 4145.0, z = 38.1, heading = 240.0},        -- Radar route rurale
    {x = 263.2, y = -1882.3, z = 26.8, heading = 320.0},        -- Radar Davis
    {x = -913.4, y = 5423.9, z = 36.5, heading = 120.0},        -- Radar North Highway
    {x = 1688.4, y = 1340.5, z = 87.5, heading = 180.0},        -- Radar Route Est
    {x = -2963.4, y = 482.8, z = 15.3, heading = 90.0},         -- Radar Pacific Bluffs
    {x = 2557.9, y = 349.8, z = 108.6, heading = 175.0},        -- Radar Tataviam Sud
    {x = -1816.8, y = 843.5, z = 138.7, heading = 130.0},       -- Radar Vinewood Hills
    {x = 1691.5, y = 6425.6, z = 32.5, heading = 65.0},         -- Radar Route Nord
    {x = 1413.2, y = 3619.8, z = 34.9, heading = 200.0},        -- Radar Sandy Shores Est
    {x = -2237.2, y = 4275.6, z = 47.8, heading = 150.0},       -- Radar Cassidy Trail
    {x = 2368.5, y = 2856.7, z = 40.1, heading = 60.0},         -- Radar Route 68 Est
    {x = -367.8, y = 4385.2, z = 58.1, heading = 245.0},        -- Radar Raton Canyon
    {x = -402.9, y = -514.5, z = 25.1, heading = 354.8}         -- Autoroute (traitre)
}

-- Création des blips pour les radars
Citizen.CreateThread(function()
    for _, radar in ipairs(radarPoints) do
        local blip = AddBlipForCoord(radar.x, radar.y, radar.z)
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

-- Fonction pour convertir la vitesse de m/s en km/h
local function msToKmh(speed)
    return speed * 3.6
end

-- Fonction pour calculer l'amende
local function calculateFine(speed)
    local speedOverLimit = speed - speedLimit
    if speedOverLimit > 0 then
        return math.floor(speedOverLimit * finePerKmh)
    end
    return 0
end

-- Fonction principale pour le contrôle radar
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) -- Vérification plus fréquente
        
        local player = PlayerPedId() -- Utilisation de PlayerPedId() au lieu de GetPlayerPed(-1)
        if IsPedInAnyVehicle(player, false) and not isProcessingRadar then
            local vehicle = GetVehiclePedIsIn(player, false)
            
            -- Vérifie si le joueur est le conducteur
            if GetPedInVehicleSeat(vehicle, -1) == player then
                -- Vérifie chaque point radar
            for _, radar in ipairs(radarPoints) do
                local playerCoords = GetEntityCoords(player)
                local distance = #(vector3(radar.x, radar.y, radar.z) - playerCoords) -- Utilisation de vector3 pour une meilleure performance

                -- Si le joueur est dans la zone du radar (100 mètres)
                if distance <= 50.0 then
                    local speed = msToKmh(GetEntitySpeed(vehicle))

                    if config.debugClient == true then
                        Wait(1000) -- Attendre 1 seconde pour une lecture plus stable
                        print("Vitesse détectée : " .. speed .. " km/h") -- Debug log
                    end

                    if speed > speedLimit then
                        isProcessingRadar = true -- Évite les doubles détections
                        local fine = calculateFine(speed)
                        
                        if config.debugClient == true then
                            print("Flash déclenché ! Vitesse : " .. speed .. " km/h") -- Debug log
                        end
                        -- Effet de flash simplifié mais efficace
                        StartScreenEffect("FocusOut", 0, false)
                        PlaySoundFrontend(-1, "Camera_Shoot", "Phone_SoundSet_Default", 1)
                        -- ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.1)
                        
                        Citizen.Wait(100)
                        
                        -- Notification immédiate
                        ESX.ShowNotification(string.format('~r~RADAR: ~w~Flashé à ~r~%.1f km/h\n~w~Amende: ~r~$%d', speed, fine))
                        
                        -- Son supplémentaire pour confirmer
                        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
                        
                        -- Retrait de l'argent
                        TriggerServerEvent('radar:payFine', fine)
                            if config.debugClient == true then
                                print("Amende envoyée au serveur : $" .. fine) -- Debug log
                            end
                            --
                        
                        -- Nettoyage des effets
                        Citizen.Wait(200)
                        StopScreenEffect("FocusOut")
                        
                        -- Reset du flag et délai avant prochain flash
                        Citizen.Wait(5000)
                        isProcessingRadar = false
                    end
                    end
                end
            end
        end
    end
end)

-- Event handler côté client pour la notification de paiement
RegisterNetEvent('radar:fineNotification')
AddEventHandler('radar:fineNotification', function(fine)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(string.format('Vous avez payé une amende de $%d', fine))
    DrawNotification(false, false)
end)