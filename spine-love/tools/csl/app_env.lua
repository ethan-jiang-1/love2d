local _M = {}
_M._env_mode = nil

function _M.get_env_mode()
    return _M._env_mode or "demo"
end

function _M.alter_env_mode(env_mode)
    print("alter env_mode to "..env_mode)
    _M._env_mode = env_mode

    local cca = require("cfg.cfg_app")
    cca.get_env_mode = _M.get_env_mode

    print("env_mode is "..cca.get_env_mode().. " now")
end

function _M.show_env()
    local cca = require("cfg.cfg_app")

    print("cca: ")
    print(" env_mode: "..cca.get_env_mode())
    print(" partner: "..cca.get_partner())
    print(" default_game_name: "..cca.get_default_game_name())
    print(" ver: "..cca.get_ver())
    print(" log_level: "..cca.get_log_level())
    print(" api_url: "..cca.get_api_url())
    print(" api_bk_url: "..cca.get_api_bk_url())
    print("")
    
    local ccup = require("cfg.cfg_cup")
    print("ccup(nvs):")
    print(" pair_env_mode: "..ccup.load_cup_data("pair_env_mode"))
    print(" child_sn: "..ccup.load_cup_data("child_sn"))
    print("")

    local ccg = require("cfg.cfg_game")
    ccg.load()
    print("ccg:".._G.inspect(ccg.cfg))

end

function _M.erase_app_env()
    local cfg_mgr = require("cfg.config_mgr")
    cfg_mgr.restore_factory()
end    

return _M