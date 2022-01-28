-- imports
local Python_AI_thinking = require "python_AI.python_AI_thinking"
local Statistics         = require "statistics.statistics"



-- Python_AI_setup
local Python_AI_setup = {}



---@param heroes CDOTA_BaseNPC_Hero[]
function Python_AI_setup:Set_context_think_for_heroes(heroes)
    Timers:CreateTimer(
        "UpdateForTeam" .. tostring(heroes[1]:GetTeam()),
        {
            ---@return number
            callback = function()
                Python_AI_thinking:On_think(heroes)
                return 0.33
            end
        }
    )
end

---@param radiant_heroes CDOTA_BaseNPC_Hero[]
---@param dire_heroes CDOTA_BaseNPC_Hero[]
function Python_AI_setup:Initialize_bot_thinking(radiant_heroes, dire_heroes)
    self:Set_statistics_collection(radiant_heroes, dire_heroes)

    self:Set_context_think_for_heroes(radiant_heroes)
    if not Settings.should_dire_be_native_bots then
        self:Set_context_think_for_heroes(dire_heroes)
    end
end

---@param radiant_heroes CDOTA_BaseNPC_Hero[]
---@param dire_heroes CDOTA_BaseNPC_Hero[]
function Python_AI_setup:Set_statistics_collection(radiant_heroes, dire_heroes)
    local collection_interval = 5

    -- To keep track of which game these statistics are part of when running
    -- multiple games without restarting Dota.
    local game_number = Settings.game_number

    Timers:CreateTimer(
        "CollectStatistics",
        {
            ---@return number
            callback = function()
                Statistics:Collect_and_send_statistics(radiant_heroes, dire_heroes, game_number)
                return collection_interval
            end
        }
    )
end



return Python_AI_setup