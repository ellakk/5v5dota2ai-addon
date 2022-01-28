-- imports
local World_data_builder = require "python_AI.world_data_builder"
local Update_handler = require "python_AI.update_handler"
local Command_controller = require "python_AI.commands.command_controller"
local Utilities = require "utilities.utilities"
local Match_end_controller = require "match_end.match_end_controller"



-- Python_AI_thinking
local Python_AI_thinking = {}

---@param heroes CDOTA_BaseNPC_Hero[]
---@param commands table
function Python_AI_thinking.On_update(heroes, commands)
    if not commands then
        return
    end
    for _index, hero in ipairs(heroes) do
        for _index, command in ipairs(commands) do
            for strhero, cmd in pairs(command) do
                if hero:GetName() == strhero then
                    if cmd.target ~= nil then
                        cmd.target = tonumber(cmd.target)
                    end
                    Command_controller:Parse_hero_command(hero, cmd)
                end
            end
        end
    end
end

-- Checks whether game clock is greater than or equal to Settings.max_game_duration. \
-- Returns `false` if Settings.max_game_duration is `-1`.
---@return boolean
function Python_AI_thinking:Game_should_end()
    if Settings.max_game_duration == -1 then
        return false
    end

    -- Settings.max_game_duration needs to be multiplied by 60 because max_game_duration is
    -- entered in minutes while GameRules:GetDOTATime(false, true) returns game clock in seconds.
    return GameRules:GetDOTATime(false, true) >= Settings.max_game_duration * 60
end

---@param heroes CDOTA_BaseNPC_Hero[]
---@return number
function Python_AI_thinking:On_think(heroes)
    if Python_AI_thinking:Game_should_end() then
        Match_end_controller:Handle_match_end()
        return
    end

    Python_AI_thinking:Before_world_building(heroes)

    local all_entities = World_data_builder:Get_all_entities(heroes[1])

    Update_handler:Update(all_entities, heroes, self.On_update)
end

---@param heroes CDOTA_BaseNPC_Hero[]
function Python_AI_thinking:Before_world_building(heroes)
    --[[
        Called before building the world data to ensure that
        certain aspects of the game world are in the correct
        state. For example, courier levels should be equal to
        hero levels (in Dota, couriers automatically level up
        with the hero, but this does not happen when the heroes
        are FakeClients)
    ]]
    for _, hero_entity in ipairs(heroes) do
        local player_id = hero_entity:GetPlayerOwnerID()
        local courier_entity = PlayerResource:GetPreferredCourierForPlayer(player_id)
        local hero_level = hero_entity:GetLevel()
        local courier_level = courier_entity:GetLevel()

        if courier_level < hero_level then
            -- The API "documentation" says that UpgradeCourier takes an int and
            -- upgrades the courier that number of times. This is not correct.
            -- UpgradeCourier sets the courier level to the integer that is passed
            -- to it and can even downgrade a courier. E.g., UpgradeCourier(1)
            -- on a level 3 courier will set it to level 1, not level 4.
            courier_entity:UpgradeCourier(hero_level)
        end
    end
end

return Python_AI_thinking