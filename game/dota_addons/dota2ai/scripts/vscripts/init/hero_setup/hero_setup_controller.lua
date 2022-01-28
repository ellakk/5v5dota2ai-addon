-- imports
local Hero_selector = require "init.hero_setup.hero_selector"
local Utilities = require "utilities.utilities"



-- constants
local ONE_SECOND_DELAY = 1.
local SIGNED_INTEGER_MAX_32_BIT = 2147483647



-- Hero_setup_controller
local Hero_setup_controller = {}

---@type CDOTA_BaseNPC_Hero[]
Hero_setup_controller.radiant_heroes = nil
---@type CDOTA_BaseNPC_Hero[]
Hero_setup_controller.dire_heroes = nil

---@return CDOTA_BaseNPC_Hero[]
function Hero_setup_controller:Get_radiant_heroes()
    return self.radiant_heroes
end

---@return CDOTA_BaseNPC_Hero[]
function Hero_setup_controller:Get_dire_heroes()
    return self.dire_heroes
end

---@return boolean
function Hero_setup_controller:All_players_have_chosen_hero()
    return Utilities:To_bool(self.radiant_heroes)
end

-- Select heroes for players 1-5 using hero names stored in Settings.
function Hero_setup_controller:Select_radiant_heroes()
    local from_player_id, to_player_id = 1, 5

    Hero_selector:Pick_heroes(
        Settings.radiant_party_names,
        DOTA_TEAM_GOODGUYS,
        from_player_id,
        to_player_id
    )
end

-- Select heroes for players 6-10 using hero names stored in Settings.
function Hero_setup_controller:Select_dire_heroes()
    local from_player_id, to_player_id = 6, 10

    Hero_selector:Pick_heroes(
        Settings.dire_party_names,
        DOTA_TEAM_BADGUYS,
        from_player_id,
        to_player_id
    )
end

-- Wait until all heroes have been chosen then store heroes of both teams.
function Hero_setup_controller:Acquire_selected_heroes()
    Timers:CreateTimer(
        ---@return number
        function()
            if not Hero_selector:All_players_have_chosen_hero() then
                return ONE_SECOND_DELAY
            end
            self.radiant_heroes = Hero_selector.radiant_heroes
            self.dire_heroes = Hero_selector.dire_heroes
        end
    )
end

-- Select heroes for each team.
function Hero_setup_controller:Select_heroes()
    self:Select_radiant_heroes()
    self:Select_dire_heroes()
    self:Acquire_selected_heroes()
end

-- Builds accessible abilities table for each hero. This table only includes abilities that can be seen, leveled up or used by a player. \
-- Special abilities that should not be accessible by the bots are filtered out and will never be sent to the python server.
---@param heroes CDOTA_BaseNPC_Hero[]
function Hero_setup_controller:Set_accessible_abilities_for_heroes(heroes)
    for _index, hero_entity in ipairs(heroes) do
        local ability_count = hero_entity:GetAbilityCount() - 1

        local key = hero_entity:GetName() .. hero_entity:GetTeam()
        Settings.accessible_abilities[key] = {}

        for index = 0, ability_count, 1 do
            local ability_entity = hero_entity:GetAbilityByIndex(index)
            if ability_entity and ability_entity:GetHeroLevelRequiredToUpgrade() ~= SIGNED_INTEGER_MAX_32_BIT then
                Settings.accessible_abilities[key][index] = ability_entity
            end
        end
    end
end

--- Builds accessible abilities tables for all radiant and dire heroes.
function Hero_setup_controller:Set_accessible_abilities_for_all_heroes()
    self:Set_accessible_abilities_for_heroes(self.radiant_heroes)
    self:Set_accessible_abilities_for_heroes(self.dire_heroes)
end

return Hero_setup_controller