--- Vehicle bounce mode.
-- @script server/main.lua

--- @section Variables
local active_bounce_modes = {}
local allowed_vehicle_hashes = {
    [Hash id ] = true,  -- Replace with actual hash ID
    [Hash id ] = true   -- Replace with actual hash ID
}

--- @section Local functions

--- Server event to stop bouncing vehicles
RegisterServerEvent('vehicle_bouncemode:sv:stop_bounce', function() 
    local _src = source
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(_src), false)
    if vehicle and vehicle ~= 0 then
        local veh_netid = NetworkGetNetworkIdFromEntity(vehicle)
        if active_bounce_modes[veh_netid] then
            active_bounce_modes[veh_netid] = nil
            TriggerClientEvent('vehicle_bouncemode:cl:stop_bounce', _src, veh_netid)
        end
    end
end)

--- Server event to toggle bouncing vehicles
RegisterServerEvent('vehicle_bouncemode:sv:toggle_bounce', function(veh_netid)
    local _src = source
    local vehicle = NetworkGetEntityFromNetworkId(veh_netid)
    local vehicle_hash = GetEntityModel(vehicle)
    if vehicle and vehicle ~= 0 and allowed_vehicle_hashes[vehicle_hash] then
        local is_bounce_mode_active = not active_bounce_modes[veh_netid]
        active_bounce_modes[veh_netid] = is_bounce_mode_active
        if is_bounce_mode_active then
            TriggerClientEvent('vehicle_bouncemode:cl:start_bounce', _src, veh_netid)
        else
            TriggerClientEvent('vehicle_bouncemode:cl:stop_bounce', _src, veh_netid)
        end
    else
        TriggerClientEvent('chat:addMessage', _src, {
            color = { 255, 0, 0 },
            multiline = true,
            args = {"System", "This vehicle is not allowed to use bounce mode."}
        })
    end
end)
