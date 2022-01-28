-- imports
local Utilities = require "utilities.utilities"



-- constants
local FULL_TEAM_COUNT = 5
local PLAYER_ADMIN_ID = 0
local ONE_SECOND_DELAY = 1.



-- Hero_selector
local Hero_selector = {}

---@type CDOTA_BaseNPC_Hero[]
Hero_selector.radiant_heroes = {}
---@type CDOTA_BaseNPC_Hero[]
Hero_selector.dire_heroes = {}

-- Hero count of both teams equal `FULL_TEAM_COUNT`. \
-- Does not count dire team when playing against native bots.
---@return boolean
function Hero_selector:All_players_have_chosen_hero()
    if Settings.should_dire_be_native_bots then
        return Utilities:Get_table_length(self.radiant_heroes) == FULL_TEAM_COUNT
    end
    return Utilities:Get_table_length(self.radiant_heroes) == FULL_TEAM_COUNT and Utilities:Get_table_length(self.dire_heroes) == FULL_TEAM_COUNT
end

-- Assign non-admin players to given team.
---@param player_id integer
---@param team integer
function Hero_selector:Put_player_on_team(player_id, team)
    if not self:Is_admin(player_id) then
        PlayerResource:SetCustomTeamAssignment(player_id, team)
    end
end

---@param player_id integer
---@param hero_name string
function Hero_selector:Select_hero_for_player(player_id, hero_name)
    PlayerResource:GetPlayer(player_id):SetSelectedHero(hero_name)
end

---@param player_id integer
---@return boolean
function Hero_selector:Player_has_not_selected_hero(player_id)
    return not PlayerResource:GetSelectedHeroEntity(player_id)
end

-- Returns reference to hero team table for of given team.
---@param team integer
---@return CDOTA_BaseNPC_Hero[]
function Hero_selector:Get_table_to_append_to(team)
    if team == DOTA_TEAM_GOODGUYS then
        return self.radiant_heroes
    end
    return self.dire_heroes
end

-- Wait until hero has been chosen for player before appending to not cause de-sync.
---@param player_id integer
---@param team integer
function Hero_selector:Append_hero_to_team_table(player_id, team)
    Timers:CreateTimer(
        function()
            if self:Player_has_not_selected_hero(player_id) then
                return ONE_SECOND_DELAY
            end

            local table_to_append_to = self:Get_table_to_append_to(team)

            table.insert(
                table_to_append_to,
                PlayerResource:GetSelectedHeroEntity(player_id)
            )
        end
    )
end

---@param player_id integer
---@return boolean
function Hero_selector:Is_admin(player_id)
    return player_id == PLAYER_ADMIN_ID
end

-- Kick player by ID.
---@param player_id integer
function Hero_selector:Kick_player(player_id)
    -- Player ids are 1-10 in Server Console, making it necessary
    -- to increase player_id by 1 before sending the kick command.
    if not Settings.spectator_mode and self:Is_admin(player_id) then
        return
    end
    SendToServerConsole("kickid " .. tostring(player_id + 1))
end

-- For each player from `from_player_id` to `to_player_id`:
-- - Assign player to given `team`.
-- - Select hero for player by corresponding index in `picked_hero_names`.
-- - Add newly created hero to hero table of given `team`.
-- - If dire should be native bots all players that belong to radiant team will be kicked. \
--   When `should_dire_be_native_bots` is enabled, BotThinking will be enabled. When BotThinking is enabled,
--   Dota will automatically start controlling the radiant heroes. \
--   If the owning players of the radiant heroes are kicked; however, Dota will not try to control the heroes.
---@param picked_hero_names string[]
---@param team integer
---@param from_player_id integer
---@param to_player_id integer
function Hero_selector:Pick_heroes(picked_hero_names, team, from_player_id, to_player_id)
    ---@type integer
    for player_id = from_player_id, to_player_id do
        local hero_name_index = player_id
        if player_id > 5 then
            hero_name_index = player_id - 5
        end

        self:Put_player_on_team(player_id, team)
        self:Select_hero_for_player(player_id, picked_hero_names[hero_name_index])
        self:Append_hero_to_team_table(player_id, team)
        if Settings.should_dire_be_native_bots and player_id <= 5 then
            self:Kick_player(player_id)
        end
    end
end

return Hero_selector