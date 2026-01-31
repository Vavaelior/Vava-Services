ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('radar:payFine', function(speed, index)
    local source = source;
    local xPlayer = ESX.GetPlayerFromId(source);

    if (not xPlayer) then
        if not config.debug then return; end
        print(string.format("[Radar] Joueur introuvable pour l'ID %s", tostring(source)));
    end

    local radarConfig <const> = config.radarPoints[index];
    if (not radarConfig) then
        if not config.debug then return; end
        print(string.format("[Radar] Configuration de radar introuvable pour l'index %s", tostring(index)));
    end

    if (speed <= 0) then
        if not config.debug then return; end
        print(string.format("[Radar] Vitesse invalide reçue: %s", tostring(speed)));
        ---Ban le joueur pour triche potentielle ici si vous le souhaitez
    end

    local speedLimit <const> = radarConfig.speedlimit or 0;
    local fine <const> = calculateFine(speed, speedLimit);

    if fine <= 0 then
        if not config.debug then return; end        
        print(string.format("[Radar] Aucune amende pour %s, vitesse: %d km/h, limite: %d km/h", GetPlayerName(source), speed, speedLimit));
        return;
    end

    local account = xPlayer.getAccount('money').money >= fine and 'money' or
                    (xPlayer.getAccount('bank').money >= fine and 'bank' or nil);

    if not account then
        xPlayer.showNotification('~r~Attention: ~w~Vous n\'avez pas assez d\'argent pour payer l\'amende!');
        if not config.debug then return; end
        local totalMoney <const> = xPlayer.getMoney() + xPlayer.getAccount('bank').money;
        print(('[Radar] %s n\'a pas pu payer son amende de $%d (argent disponible: $%d)'):format(GetPlayerName(source), fine, totalMoney));
        return;
    end

    xPlayer.removeAccountMoney(account, fine);
    xPlayer.showNotification(('~r~Radar: Vous avez été flashé à %s! ~s~Amende payée: ~r~$%d'):format(speed, fine));
    xPlayer.triggerEvent('radar:updateBillState');
    if not config.debug then return; end
    print(('[Radar] %s a payé une amende de $%d depuis %s'):format(GetPlayerName(source), fine, account)) -- Debug log
end)
