-- imports
local Game_state_controller = require "game_states.game_state_controller"



---@type fun(entered_chat_string: string)[]
local player_chat_callbacks = {}
---@type fun()[]
local hero_selection_game_state_callbacks = {}
---@type fun()[]
local pre_game_state_callbacks = {}
---@type fun()[]
local in_progress_game_state_callbacks = {}
---@type fun()[]
local post_game_state_callbacks = {}

---@param callbacks fun()[]
local function Run_callbacks(callbacks)
    for _index, callback in ipairs(callbacks) do
        callback()
    end
end



-- Event_controller \
-- Using a "pub-sub"-like pattern, allowing any number of callbacks to be run on certain events.
local Event_controller = {}



-- Start listening to game events:
-- - game_rules_state_change ( When state changes, e.g., selection state, pre game state. )
-- - `player_chat` ( When a player sends a message using chat. )
function Event_controller:Initialize_listeners()
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap( Event_controller, "On_game_state_change" ), self)
    ListenToGameEvent("player_chat", Dynamic_Wrap( Event_controller, "On_player_chat" ), self)
end



-- Run all callbacks "subscribing" to `player_chat` event.
---@param event_args table event_args.text - entered chat string.
function Event_controller:On_player_chat(event_args)
    for _index, callback in ipairs(player_chat_callbacks) do
        callback(event_args.text)
    end
end



-- Run all callbacks "subscribing" to `game_rules_state_change` event matching current game state condition.
function Event_controller:On_game_state_change()
    if Game_state_controller:Is_hero_selection_state() then
        Run_callbacks(hero_selection_game_state_callbacks)

    elseif Game_state_controller:Is_pre_game_state() then
        Run_callbacks(pre_game_state_callbacks)

    elseif Game_state_controller:Is_game_in_progress_state() then
        Run_callbacks(in_progress_game_state_callbacks)

    elseif Game_state_controller.Is_post_game_state() then
        Run_callbacks(post_game_state_callbacks)

    end
end



-- Add "subscriber" callback function to run on selection game state.
---@param callback fun()
function Event_controller:Add_on_hero_selection_game_state_listener(callback)
    table.insert(hero_selection_game_state_callbacks, callback)
end

-- Add "subscriber" callback function to run on pre game state.
---@param callback fun()
function Event_controller:Add_on_pre_game_state_listener(callback)
    table.insert(pre_game_state_callbacks, callback)
end

-- Add "subscriber" callback function to run on in progress game state.
---@param callback fun()
function Event_controller:Add_on_in_progress_game_state_listener(callback)
    table.insert(in_progress_game_state_callbacks, callback)
end

-- Add "subscriber" callback function to run on post game state.
---@param callback fun()
function Event_controller:Add_on_post_game_state_listener(callback)
    table.insert(post_game_state_callbacks, callback)
end

-- Add "subscriber" callback function to run on player chat event.
---@param callback fun(entered_chat_string: string)
function Event_controller:Add_on_player_chat_listener(callback)
    table.insert(player_chat_callbacks, callback)
end



return Event_controller