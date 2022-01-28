-- Game_state_controller \
-- Test for different game states.
local Game_state_controller = {}

---@return boolean
function Game_state_controller:Is_hero_selection_state()
    return GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION
end

---@return boolean
function Game_state_controller:Is_pre_game_state()
    return GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME
end

---@return boolean
function Game_state_controller:Is_game_in_progress_state()
    return GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS
end

---@return boolean
function Game_state_controller:Is_post_game_state()
    return GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME
end

return Game_state_controller