local speedometerVisible = true
local inVehicle = false
local config = {
    useImperial = true,
    passengerCanSee = false,
    hideKey = 'H'
}

function round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function getVehicleSpeed()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    local speed = GetEntitySpeed(vehicle)
    
    if config.useImperial then
        return round(speed * 2.236936, 0) -- Convert to MPH
    else
        return round(speed * 3.6, 0) -- Convert to KPH
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        local player = PlayerPedId()
        
        if IsPedInAnyVehicle(player, false) then
            if not inVehicle then
                inVehicle = true
                if speedometerVisible then
                    SendNUIMessage({type = "showSpeedometer", blur = "in"})
                end
            end
            
            if (GetPedInVehicleSeat(GetVehiclePedIsIn(player, false), -1) == player) or config.passengerCanSee then
                local speed = getVehicleSpeed()
                SendNUIMessage({
                    type = "updateSpeed",
                    speed = speed,
                    unit = config.useImperial and "MPH" or "KPH"
                })
            end
        else
            if inVehicle then
                inVehicle = false
                SendNUIMessage({type = "showSpeedometer", blur = "out"})
            end
        end
    end
end)

RegisterCommand('toggleSpeedometer', function()
    speedometerVisible = not speedometerVisible
    if speedometerVisible and inVehicle then
        SendNUIMessage({type = "showSpeedometer", blur = "in"})
    else
        SendNUIMessage({type = "showSpeedometer", blur = "out"})
    end
end)

RegisterKeyMapping('toggleSpeedometer', 'Toggle Speedometer', 'keyboard', config.hideKey)