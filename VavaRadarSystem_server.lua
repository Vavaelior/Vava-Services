ESX = exports['es_extended']:getSharedObject()

-- Enregistrement de l'événement pour le paiement de l'amende
RegisterServerEvent('radar:payFine')
AddEventHandler('radar:payFine', function(fine)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        -- Vérifie d'abord l'argent liquide
        if xPlayer.getMoney() >= fine then
            xPlayer.removeMoney(fine)
            TriggerClientEvent('esx:showNotification', source, string.format('~r~Radar: ~w~Amende payée: ~r~$%d', fine))
            if config.debug == true then
                print(string.format("[Radar] %s a payé une amende de $%d", GetPlayerName(source), fine)) -- Debug log
            end
        
        -- Sinon vérifie l'argent en banque
        elseif xPlayer.getAccount('bank').money >= fine then
            xPlayer.removeAccountMoney('bank', fine)
            TriggerClientEvent('esx:showNotification', source, string.format('~r~Radar: ~w~Amende prélevée du compte bancaire: ~r~$%d', fine))
            if config.debug == true then
                print(string.format("[Radar] %s a payé une amende de $%d depuis son compte bancaire", GetPlayerName(source), fine)) -- Debug log
            end
        
        -- Si pas assez d'argent du tout
        else
            local totalMoney = xPlayer.getMoney() + xPlayer.getAccount('bank').money
            TriggerClientEvent('esx:showNotification', source, '~r~Attention: ~w~Vous n\'avez pas assez d\'argent pour payer l\'amende!')
            if config.debug == true then
                print(string.format("[Radar] %s n'a pas pu payer son amende de $%d (argent disponible: $%d)", GetPlayerName(source), fine, totalMoney))
            end

            -- Option: Vous pouvez ajouter ici une dette, un wanted level, ou autre conséquence
        end
    end
end)

-- Événement pour sauvegarder les statistiques des radars (optionnel)
RegisterServerEvent('radar:logSpeed')
AddEventHandler('radar:logSpeed', function(speed, location)
    local source = source
    if config.debug == true then
        print(string.format("[Radar] %s a été flashé à %d km/h à %s", GetPlayerName(source), math.floor(speed), location)) -- Debug log
    end
end)