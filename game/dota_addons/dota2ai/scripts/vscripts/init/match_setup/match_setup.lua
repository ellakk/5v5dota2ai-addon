-- Match_setup
local Match_setup = {}

function Match_setup:Set_bot_thinking_enabled()
    ---@type table
    local GameMode = GameRules:GetGameModeEntity()
    GameMode:SetBotThinkingEnabled(true)
end

-- Selection time, showcase time, strategy time and game setup time are all set to 1 second. \
-- Pre-game time is set to 90 seconds if game should have pre game time (defined in Settings).
function Match_setup:Remove_all_game_rule_starting_delays()
    GameRules:SetHeroSelectionTime(1.)
    GameRules:SetShowcaseTime(1.)
    GameRules:SetStrategyTime(1.)
    GameRules:SetCustomGameSetupTimeout(1.)
    if Settings.should_have_pre_game_delay then
        GameRules:SetPreGameTime(90.)
    end
end

-- Allows both teams to see each other, meaning data of all entities are sent to both python-bot. \
-- Note: Granting global vision is a cheat and should only be used for testing, not for simply spectating the game. \
-- ( If you want to spectate the game, set `spectator_mode` to `true` in settings.json. )
function Match_setup:Grant_global_vision()
    --[[
        Some console commands are not reset on restart.
        This if-statement must therefore have an else-branch for "dota_all_vision" to work properly when switching grant_global_vision setting between restarts.
    ]]
    if Settings.grant_global_vision then
        SendToServerConsole("dota_all_vision 1")
    else
        SendToServerConsole("dota_all_vision 0")
    end
end

-- Finish game setup after 1 second.
function Match_setup:Auto_launch_custom_game()
    Timers:CreateTimer({
        endTime = 1.,
        callback = function()
            GameRules:FinishCustomGameSetup()
        end
    })
end

-- Populate game with bots.
function Match_setup:Populate_game()
    SendToServerConsole("dota_bot_populate")
end

-- Start spawning creeps.
function Match_setup:Force_game_start()
    SendToServerConsole("dota_dev forcegamestart")
end

-- Enable default runes.
function Match_setup:Enable_runes()
    ---@type table
    local GameMode = GameRules:GetGameModeEntity()
    GameMode:SetUseDefaultDOTARuneSpawnLogic(true)
end

function Match_setup:Enable_courier()
    -- 'Free Courier Mode' is the style of couriers introduced in patch 7.23 where
    -- each hero gets a free courier.
    GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
end

function Match_setup:Start_day_night_cycle()
    GameRules:SetTimeOfDay(0.251)
end

-- Run game setup. \
-- - Enable bot thinking if needed.
-- - Enable day night cycle.
-- - Enable/disable global vision.
-- - Enable runes.
-- - Enable courier.
-- - Launch game.
function Match_setup:Run()
    self:Auto_launch_custom_game()
    if Settings.should_dire_be_native_bots then
        self:Set_bot_thinking_enabled()
    end
    self:Remove_all_game_rule_starting_delays()
    self:Start_day_night_cycle()
    self:Grant_global_vision()
    self:Enable_runes()
    self:Enable_courier()
end

return Match_setup