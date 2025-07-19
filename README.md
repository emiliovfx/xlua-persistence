# xlua-persistence

A lightweight JSON persistence module for X-Plane's xlua plugin.

## Features

- Save and load aircraft state to `.json`
- Simple JSON encoding/decoding
- Offline time simulation with `os.time()` support
- Designed for use with `find_dataref()` datarefs
- Minimal and dependency-free

## Usage

```lua
local json_path = "some/path/ACF_data.json"
local data = {
    barometer = simDR_barometer_setting,
    battery_charge = simDR_battery_charge,
    -- etc...
}
save_to_json(json_path, data)

local loaded = load_from_json(json_path)
if loaded.barometer then simDR_barometer_setting = loaded.barometer end
```

## License

MIT
