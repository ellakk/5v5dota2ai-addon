local Statistics = require "statistics.statistics"

local Match_end_controller = {}

-- end_flag is set to `true` when Match_end_controller:Handle_match_end() is called.
-- If end_flag is `true` then `game_ended` request will not be made,
-- preventing more than 1 match_end per game.
local end_flag = false

-- Runs console command "dota_launch_custom_game Dota2-AI-Framework dota", forcing a restart provided Addon has the name "Dota2-AI-Framework".
local function Restart()
    SendToServerConsole("dota_launch_custom_game Dota2-AI-Framework dota")
end

-- Stops game by kicking running admin. \
-- Note: does not inform server of exit.
local function Exit()
    SendToServerConsole("kickid 1")
end

-- Informs server of game end. Use server response to determine whether to restart addon or to exit game.
function Match_end_controller:Handle_match_end()
    if end_flag then
        return
    end

    end_flag = true

    local end_game_stats = Statistics:Collect_end_game(Settings.game_number)
    local body = package.loaded["game/dkjson"].encode(end_game_stats)

    ---@type table
    local request = CreateHTTPRequestScriptVM("POST", "http://localhost:8080/api/game_ended")
    request:SetHTTPRequestHeaderValue("Accept", "application/json")
    request:SetHTTPRequestRawPostBody("application/json", body)
    request:Send(
        ---@param response_json table
        function(response_json)
            ---@type table
            local response = package.loaded["game/dkjson"].decode(response_json["Body"])
            if response.status == "restart" then
                Restart()
            elseif response.status == "done" then
                Exit()
            end
        end
    )
end

-- Informs server of restart, then restarts addon.
function Match_end_controller:Handle_restart_game()
    ---@type table
    local request = CreateHTTPRequestScriptVM("POST", "http://localhost:8080/api/restart_game")
    request:Send(
        ---@param response_json table
        function(response_json)
            Restart()
        end
    )
end

-- Restart addon without informing server.
function Match_end_controller:Force_restart()
    Restart()
end

-- Stop game.
function Match_end_controller:Handle_exit()
    Exit()
end

return Match_end_controller