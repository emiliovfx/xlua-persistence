--*************************************************************************************--
--**                          Example Usage for xlua-persistence                     **--
--*************************************************************************************--

simDR_barometer_setting = find_dataref("sim/cockpit/misc/barometer_setting")
simDR_battery_charge = find_dataref("sim/cockpit/electrical/battery_charge_watt_hr")

local json_path = "plugins/xlua/scripts/ACF_data/ACFData.json"

function aircraft_unload()
    local data = {
        barometer = simDR_barometer_setting,
        battery_charge = simDR_battery_charge,
        timestamp = os.time()
    }
    save_to_json(json_path, data)
end

function aircraft_load()
    local data = load_from_json(json_path)
    if data.barometer then simDR_barometer_setting = data.barometer end
    if data.battery_charge then simDR_battery_charge = data.battery_charge end
end
