---Les functions suivantes peuvent être utilisées à la fois côté client et côté serveur à vous de voir si vous voulez optimiser le reseau ou pas (actuellement pas le cas)
ESX = exports['es_extended']:getSharedObject();

---@param speed number
---@param speedLimit number
---@return number
function calculateFine(speed, speedLimit)
    local speedOverLimit = speed - speedLimit
    return speedOverLimit > 0 and math.floor(speedOverLimit * config.finePerKmh) or 0;
end

---@param speed number
---@return number
function msToKmh(speed)
    return speed * 3.6;
end