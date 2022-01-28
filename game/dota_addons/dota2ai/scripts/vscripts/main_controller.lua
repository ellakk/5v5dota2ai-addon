-- imports
local Settings_setup = require "init.settings_setup"
local Event_controller = require "listeners.event_controller"
local Match_setup_controller = require "init.match_setup.match_setup_controller"
local Hero_setup_controller = require "init.hero_setup.hero_setup_controller"
local Python_AI_controller = require "python_AI.python_AI_controller"
local Match_end_controller = require "match_end.match_end_controller"



-- constants
local ONE_SECOND_DELAY = 1.0
local ADMIN_PLAYER_ID = 0
local SPECTATOR_TEAM = 1



-- Wait until all bots have chosen a hero then: \
-- Build global table `accessible_abilities` for filtering which ability data should be sent to server for each hero. \
-- Start bot thinking process.
---@return number | nil
function Main_controller.Initialize_bot_thinking()
    if not Hero_setup_controller:All_players_have_chosen_hero() then
        return ONE_SECOND_DELAY
    end

    Hero_setup_controller:Set_accessible_abilities_for_all_heroes()

    Python_AI_controller:Initialize_bot_thinking(
        Hero_setup_controller:Get_radiant_heroes(),
        Hero_setup_controller:Get_dire_heroes()
    )
end

function Main_controller.Select_heroes_after_populate_game()
    Hero_setup_controller:Select_heroes()
    Timers:CreateTimer(Main_controller.Initialize_bot_thinking)
end

-- Populate game with bots. \
-- Wait 1 second to ensure game is populated before continuing.
function Main_controller.On_hero_selection_game_state()
    Match_setup_controller:Populate_game()
    Timers:CreateTimer({
        endTime = 1.0,
        callback = Main_controller.Select_heroes_after_populate_game
    })
end

-- Start spawning creeps immediately if game should not have pre game time. \
-- Else keep default pre game time.
function Main_controller.On_pre_game_state()
    if not Settings.should_have_pre_game_delay then
        Match_setup_controller:Force_game_start()
    end
end

function Main_controller.On_post_game_state()
    Match_end_controller:Handle_match_end()
end

-- Handles player chat commands.
---@param chat_input string Player input.
function Main_controller.On_player_chat(chat_input)
    if chat_input == "end" then
        Match_end_controller:Handle_match_end()
    elseif chat_input == "restart" then
        Match_end_controller:Handle_restart_game()
    elseif chat_input == "exit" then
        Match_end_controller:Handle_exit()
    end
end

function Main_controller:Put_admin_on_spectator_team()
    PlayerResource:GetPlayer(ADMIN_PLAYER_ID):SetTeam(SPECTATOR_TEAM)
end

-- Determine and set spectator mode. \
-- Start listening to game events. \
-- Run match setup.
function Main_controller.Run_after_settings()
    if Settings.spectator_mode then
        Main_controller:Put_admin_on_spectator_team()
    end
    Event_controller:Initialize_listeners()
    Match_setup_controller:Initialize_match_setup()
    Event_controller:Add_on_hero_selection_game_state_listener(Main_controller.On_hero_selection_game_state)
    Event_controller:Add_on_pre_game_state_listener(Main_controller.On_pre_game_state)
    Event_controller:Add_on_in_progress_game_state_listener(Main_controller.in_progress_game_state_callbacks)
    Event_controller:Add_on_post_game_state_listener(Main_controller.On_post_game_state)
    Event_controller:Add_on_player_chat_listener(Main_controller.On_player_chat)
end

-- Request Settings from server. \
-- Wait 1 second to ensure settings has been collected before continuing.
function Main_controller.Run()
    Settings_setup:Get_and_set_settings()
    Timers:CreateTimer({
        endTime = 1.0,
        callback = Main_controller.Run_after_settings
    })
end