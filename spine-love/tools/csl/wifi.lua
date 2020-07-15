local _M = {}

local function _connect_wifi(ssid, pwd)
    print("try to connect to ssid: "..tostring(ssid).." pwd: "..tostring(pwd))
    local wac = require("dl_net.wifi_access_connect")
    local wa = require("net.wifi_access")
    local ret = wac.start_sta_connect_one(ssid, pwd)
    if _G.thread then
        _G.thread.sleepms(1000)
    end
    if _G.net.connected() and _G.net.wan_connected() then
        print("Successful to connect network, Wifi: ".. tostring(ssid).." Mode: ".. wa.get_wifi_mode_name())
    else
        print("Failed to connect to network via Wifi: "..tostring(ssid))
    end
    return ret
end

function _M.wifi_enable(on_or_off)
    if on_or_off then
        print("try to turn on wifi")
    else
        print("try to turn off wifi")
    end
    local wa = require("net.wifi_access")
    if on_or_off then
        local ssid = "GULULU-2.4"
        local pwd = "Bowhead311"
        _connect_wifi(ssid, pwd)
    else
        wa.stop_wifi()
        if not _G.net.connected() then
            print("Wifi is off: ".. wa.get_wifi_mode_name())
        end
    end
end


return _M