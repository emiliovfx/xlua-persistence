--*************************************************************************************--
--**                              XLUA PERSISTENCE MODULE                           **--
--*************************************************************************************--

-- Usage:
-- 1. Assign writable datarefs to variables prefixed like simDR_*
-- 2. Define a table 'data' in save_to_json() with keys mapping to those datarefs
-- 3. Adjust brightness handling or nested tables as needed per aircraft

--*************************************************************************************--
--**                         MINIMAL JSON DECODER (FLAT/NESTED)                    **--
--*************************************************************************************--

function json_decode(str)
    local json = {}
    str = str:gsub('^%s*{(.-)}%s*$', '%1')
    for k, v in str:gmatch('"(.-)"%s*:%s*([^,}]+)') do
        v = v:gsub(',$', ''):gsub('}', '')
        if v:sub(1, 1) == '"' and v:sub(-1) == '"' then
            json[k] = v:sub(2, -2)
        elseif v:sub(1, 1) == '{' then
            local inner = {}
            for ik, iv in v:gmatch('"(.-)"%s*:%s*([%d%.%-]+)') do
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

--*************************************************************************************--
--**                              SAVE / LOAD TEMPLATE                             **--
--*************************************************************************************--

function save_to_json(filepath, data_table)
    local file, err = io.open(filepath, "w")
    if not file then print("Error writing JSON: " .. err) return end

    local json = "{\n"
    for key, val in pairs(data_table) do
        json = json .. string.format('  "%s": %s,\n', key, value_to_json(val))
    end
    json = json:sub(1, -3) .. "\n}\n"
    file:write(json)
    file:close()
end

function load_from_json(filepath)
    local file = io.open(filepath, "r")
    if not file then print("JSON not found: " .. filepath) return {} end
    local content = file:read("*all")
    file:close()
    return json_decode(content)
end
