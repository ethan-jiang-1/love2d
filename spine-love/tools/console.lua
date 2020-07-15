local _M = {}

local lock_reason_console = ""

local function cf_load_app_module(modname)
    local csl_app_module = require("tools.csl.app_module")
    return csl_app_module.load_app_module(modname)
end

local function cf_list_global(mode)
    local csl_global = require("tools.csl.global")
    return csl_global.list_global(mode)
end

local function cf_wifi_enable(on_or_off)
    local csl_wifi = require("tools.csl.wifi")
    csl_wifi.wifi_enable(on_or_off)
end

local function cf_change_env_mode(env_mode)
    local csl_env_mode = require("tools.csl.app_env")
    csl_env_mode.alter_env_mode(env_mode)
end
local function cf_show_env()
    local csl_env_mode = require("tools.csl.app_env")
    csl_env_mode.show_env()
end
local function cf_erase_app_nvs()
   local csl_env_mode = require("tools.csl.app_env")
    csl_env_mode.erase_app_env()
end


local function cf_help()
    print("inspect(obj)             to inspect object")
    print("dbg(boolean)             to set up breakpoint")
    print("")
    print("console:help()           to show this help")
    print("console:global(mode)     to list top names by mode: table, function, others and all ")
    print("console:load(mname)      to load and init module and assign to globals")
    print("console:wifi_on()        to turn wifi on")
    print("console:wifi_off()       to turn wifi off")
    print("console:no_sleep()       to turn powermanager off")
    print("console:sleep()          to turn powermanager on")
    print("console:ce_development() to change env_mode to development")
    print("console:ce_staging()     to change env_mode to development")
    print("console:ce_production()  to change env_mode to production")
    print("console:show_env()       to show all app_env")
    print("console:erase_app_nvs()  to earse all app nvs data")
end

local console_mt = {}
console_mt.__index = console_mt
function console_mt.help(self) -- luacheck:ignore
    cf_help()
end
function console_mt.global(self, mode) -- luacheck:ignore
    cf_list_global(mode)
end
function console_mt.load(self, module_name)  -- luacheck:ignore
    cf_load_app_module(module_name)
end
function console_mt.wifi_on(self)  -- luacheck:ignore
    cf_wifi_enable(true)
end
function console_mt.wifi_off(self)  -- luacheck:ignore
    cf_wifi_enable(false)
end
function console_mt.no_sleep(self) -- luacheck:ignore
    --if _G.pm then
    --    _G.pm.lock_acquire(0)
    --end
    local PMC = require("power.power_manager")
    if lock_reason_console ~= "" then
        PMC.safe_pm_lock_release(PMC.PM_LOCK_LCD, lock_reason_console)
    end
    lock_reason_console = PMC.get_lock_reason("console_no_sleep")
    PMC.safe_pm_lock_acquire(PMC.PM_LOCK_LCD, lock_reason_console)
end
function console_mt.sleep(self) -- luacheck:ignore
    --if _G.pm then
    --    _G.pm.lock_release(0)
    --end
    if lock_reason_console ~= "" then
        local PMC = require("power.power_manager")
        PMC.safe_pm_lock_release(PMC.PM_LOCK_LCD, lock_reason_console)
        lock_reason_console = ""
    end
end
function console_mt.ce_development(self) --luacheck:ignore
    cf_change_env_mode("development")
end
function console_mt.ce_staging(self) --luacheck:ignore
    cf_change_env_mode("staging")
end
function console_mt.ce_production(self) --luacheck:ignore
    cf_change_env_mode("production")
end
function console_mt.show_env(self) --luacheck:ignore
    cf_show_env()
end
function console_mt.erase_app_nvs(self) --luacheck:ignore
    cf_erase_app_nvs()
end

local function new_console()
    _G.console = {}
    return setmetatable(_G.console, console_mt)
end

local function load_tools()
    _G.inspect = require("tools.inspect").inspect
    _G.console = new_console()
    print("tools: inspect() function and console object are loaded.")
    _G.console:no_sleep()
    cf_help()
end


local function load_console()
    pcall(require, "dev_env")
    load_tools()
end


load_console()

return _M