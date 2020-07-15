local hm = require("tools.hook.hook_module")

local _M = {}

local gnames = {"sys", "sys_cmd",
                "audio", "ai_audio",
                "pm", "msgq",
                "net", "net_game",
                "nvs", "lvgl"}

function _M.enable_hooks()
    for _, name in ipairs(gnames) do 
        if type(_G[name]) == "table" then
            print("hook internal global: "..name)
            hm.hook_module_tick_in_global(_G[name], name)
        end
    end
end

return _M