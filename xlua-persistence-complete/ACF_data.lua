--*************************************************************************************--
--**                        FULL INTEGRATION EXAMPLE FOR XLUA                      **--
--*************************************************************************************--

-- Include this file in your xlua aircraft script folder (e.g. ACF_data.lua)
-- Demonstrates dataref tracking, JSON save/load using the persistence module

--*************************************************************************************--
--**                               DATAREF DEFINITIONS                             **--
--*************************************************************************************--

simDR_dataref_name1 = find_dataref("dataref_name1")
simDR_dataref_name2 = find_dataref("dataref_name2")
simDR_dataref_array = find_dataref("dataref_array_name") -- assumes indexed values like simDR_dataref_array[1]

--*************************************************************************************--
--**                               FILE PATH SETUP                                 **--
--*************************************************************************************--

acf_path = find_dataref("sim/aircraft/view/acf_relative_path")
acf_folder = string.match(acf_path, "(.-)[^/]+$")
json_path = acf_folder .. "plugins/xlua/scripts/ACF_data/ACF_data.json"

--*************************************************************************************--
--**                         IMPORT PERSISTENCE MODULE INLINE                       **--
--*************************************************************************************--

function json_decode(str)
    local json = {}
    str = str:gsub('^%s*{(.-)}%s*$', '%1')
    for k, v in str:gmatch('"(.+)"%s*:%s*([^,}]+)') do
        v = v:gsub(',$', ''):gsub('}', '')
        if v:sub(1, 1) == '"' and v:sub(-1) == '"' then
            json[k] = v:sub(2, -2)
        elseif v:sub(1, 1) == '{' then
            local inner = {}
            for ik, iv in v:gmatch('"(.+)"%s*:%s*([%d%.%-]+)') do
                inner[tonumber(ik)] = tonumber(iv)
            end
            json[k] = inner
        else
            json[k] = tonumber(v) or v
        end
    end
    return json
end

function value_to_json(v)
    if type(v) == "string" then
        return '"' .. v .. '"'
    elseif type(v) == "number" then
        return tostring(v)
    elseif type(v) == "table" then
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = ('"%s":%s'):format(k, value_to_json(val))
        end
        return "{" .. table.concat(parts, ",") .. "}"
    else
        return "null"
    end
end

function save_to_json(filepath)
    local data = {
        dataref_name1 = simDR_dataref_name1,
        dataref_name2 = simDR_dataref_name2,
        dataref_array = {
            [1] = simDR_dataref_array[1],
            [2] = simDR_dataref_array[2],
            [3] = simDR_dataref_array[3]
        }
    }
    local file, err = io.open(filepath, "w")
    if not file then print("Error writing JSON: " .. err) return end

    local json = "{\n"
    for key, val in pairs(data) do
        json = json .. string.format('  "%s": %s,\n', key, value_to_json(val))
    end
    json = json:sub(1, -3) .. "\n}\n"
    file:write(json)
    file:close()
end

function load_from_json(filepath)
    local file = io.open(filepath, "r")
    if not file then print("JSON not found: " .. filepath) return end
    local content = file:read("*all")
    file:close()
    local data = json_decode(content)
    if data.dataref_name1 then simDR_dataref_name1 = data.dataref_name1 end
    if data.dataref_name2 then simDR_dataref_name2 = data.dataref_name2 end
    if data.dataref_array then
        for i = 1, 3 do
            if data.dataref_array[i] then simDR_dataref_array[i] = data.dataref_array[i] end
        end
    end
end

--*************************************************************************************--
--**                             AIRCRAFT CALLBACKS                                 **--
--*************************************************************************************--

function aircraft_load()
    load_from_json(json_path)
    print("[xlua-persistence] Data loaded from JSON.")
end

function aircraft_unload()
    save_to_json(json_path)
    print("[xlua-persistence] Data saved to JSON.")
end
