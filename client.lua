--- Vehicle bounce mode.

-- @script client/main.lua

--- @section Variables 

local is_bounce_mode_active = false
local bounce_height = 0.0
local original_height = {}
local bounce_time = 0
local allowed_vehicle_types = { 0, 1, 2, 3, 4, 5, 6, 7 }
local allowed_vehicle_hashes = {
    [Hash id ] = true,  -- Replace with actual hash ID
    [Hash id ] = true   -- Replace with actual hash ID
}
local original_speed_limits = {}

--- Check if a table contains a value
-- @param table table: the table to check
-- @param element any: the element to look for
-- @return boolean: true if element is in table, false otherwise
local function table_contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

--- Toggle bounce for single vehicle
-- @param vehicle number: vehicle ID to toggle bounce for
local function toggle_for_single_vehicle(vehicle)
    local current_speed = GetEntitySpeed(vehicle) * 3.6 -- Convert m/s to km/h
    if current_speed > 50 then
        -- Speed is over 50 km/h, do not activate bounce mode
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = {"System", "Cannot activate bounce mode while speed is over 50 km/h."}
        })
        return
    end
    
    is_bounce_mode_active = not is_bounce_mode_active
    bounce_time = GetGameTimer()
    if is_bounce_mode_active then
        original_height[vehicle] = GetVehicleSuspensionHeight(vehicle)
        original_speed_limits[vehicle] = GetVehicleMaxSpeed(vehicle)
        SetVehicleLights(vehicle, 2)
        SetVehicleFullbeam(vehicle, true)
        SetVehicleMaxSpeed(vehicle, 4.0)
    else
        SetVehicleSuspensionHeight(vehicle, original_height[vehicle] or 0)
        SetVehicleLights(vehicle, 0)
        SetVehicleFullbeam(vehicle, false)
        SetVehicleMaxSpeed(vehicle, original_speed_limits[vehicle] or GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"))
    end
end

--- Toggle vehicle bounce mode on or off
local function toggle_vehicle_bounce_mode(veh_netid)
    local vehicle = NetworkGetEntityFromNetworkId(veh_netid)
    local vehicle_hash = GetEntityModel(vehicle)
    if vehicle ~= 0 and allowed_vehicle_hashes[vehicle_hash] then
        toggle_for_single_vehicle(vehicle)
    end
end

--- Toggle vehicle bounce mode using the keybind
RegisterCommand('veh_bounce_keybind', function()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    if vehicle ~= 0 then
        local veh_netid = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('vehicle_bouncemode:sv:toggle_bounce', veh_netid)
    end
end, false)

--- Register the key mapping for vehicle bounce mode
RegisterKeyMapping('veh_bounce_keybind', 'Toggle Vehicle Bounce Mode', 'keyboard', 'B')

--- Handles vehicle bouncing.
CreateThread(function()
    while true do
        Wait(0)
        if is_bounce_mode_active then
            local current_time = GetGameTimer()
            local time_since_start = (current_time - bounce_time) / 1000.0
            local new_bounce_height = 0.05 * math.sin(2 * math.pi * 1.5 * time_since_start)
            
            for vehicle, height in pairs(original_height) do
                SetVehicleSuspensionHeight(vehicle, height + new_bounce_height)
            end
        end
    end
end)

--- Triggers event from server to start bouncing.
RegisterNetEvent('vehicle_bouncemode:cl:start_bounce', function(veh_netid)
    toggle_vehicle_bounce_mode(veh_netid)
end)

--- Triggers event from server to stop bouncing.
RegisterNetEvent('vehicle_bouncemode:cl:stop_bounce', function(veh_netid)
    toggle_vehicle_bounce_mode(veh_netid)
end)
