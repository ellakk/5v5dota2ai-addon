local Hero_setup_controller = require "init.hero_setup.hero_setup_controller"
local Utilities = require "utilities.utilities"

local Statistics = {}

-- Collects the statistics that are sent to the /api/game_ended route
---@param game_number integer
---@return table
function Statistics:Collect_end_game(game_number)
    local stats = {}
    local radiant_heroes = Hero_setup_controller:Get_radiant_heroes()
    local dire_heroes = Hero_setup_controller:Get_dire_heroes()
    local heroes = Utilities:Concat_lists(radiant_heroes, dire_heroes)

    stats["game_number"] = game_number
    stats["end_stats"] = {}
    stats["end_stats"]["game_time"] = GameRules:GetDOTATime(false, true)
    stats["end_stats"]["radiant"] = {}
    stats["end_stats"]["dire"] = {}

    for _, hero in ipairs(heroes) do
        local hero_stats = Statistics:Hero_end_game_stats(hero)
        local hero_name = hero:GetName()
        local team = hero:GetTeam() == 2 and "radiant" or "dire"
        stats["end_stats"][team][hero_name] = hero_stats
    end

    return stats
end

--[[
    Collects end game statistics for a specific hero.
    These are intended to match what is shown on the actual end-game screen.
]]
---@param hero CDOTA_BaseNPC_Hero
---@return table
function Statistics:Hero_end_game_stats(hero)
    local stats = {}
    stats["id"] = hero:GetPlayerID()
    stats["kills"] = hero:GetKills()
    stats["deaths"] = hero:GetDeaths()
    stats["assists"] = hero:GetAssists()
    stats["net_worth"] = "not implemented"
    stats["items"] = "not implemented"
    stats["backpack"] = "not implemented"
    stats["buffs"] = "not implemented"
    stats["last_hits"] = hero:GetLastHits()
    stats["denies"] = hero:GetDenies()
    stats["gold_per_min"] = "not implemented"
    stats["bounty_runes"] = "not implemented"
    stats["xpm"] = "not implemented"
    stats["heal"] = "not implemented"
    stats["outposts"] = "not implemented"
    stats["dmg_dealt_hero"] = "not implemented"
    stats["dmg_dealt_building"] = "not implemented"
    stats["dmg_received_raw"] = "not implemented"
    stats["dmg_received_reduced"] = "not implemented"
    stats["death_loss_gold"] = "not implemented"
    stats["death_loss_time"] = "not implemented"
    stats["pick"] = "not implemented"
    return stats
end


--[[
    This function sends statistics to the /api/statistics route.
    These are the statistics that are sent continuously during the game.
]]
---@param radiant_heroes CDOTA_BaseNPC_Hero[] radiant hero entities.
---@param dire_heroes CDOTA_BaseNPC_Hero[] dire hero entities.
---@param game_number integer
function Statistics:Collect_and_send_statistics(radiant_heroes, dire_heroes, game_number)
    local statistics = Statistics:Collect_statistics(radiant_heroes, dire_heroes, game_number)
    Statistics:Send_statistics(statistics)
end


---@param radiant_heroes CDOTA_BaseNPC_Hero[] radiant hero entities.
---@param dire_heroes CDOTA_BaseNPC_Hero[] dire hero entities.
---@param game_number integer
function Statistics:Collect_statistics(radiant_heroes, dire_heroes, game_number)
    local heroes = Utilities:Concat_lists(radiant_heroes, dire_heroes)
    local stats = {}
    local fields = {}

    stats["game_number"] = game_number

    -- General game statistics that are not tied to a particular hero.
    -- There is also GameRules:GetGameTime() but that one includes time in menus.
    -- Menu time is turned off in this command by setting the first argument to false.
    fields["game_time"] = GameRules:GetDOTATime(false, true)

    -- Hero specific stats.
    for i, hero in ipairs(heroes) do
        local player_id = hero:GetPlayerID()
        local team = hero:GetTeam()

        --[[
            Note to future developers: collection of data concerning
            damage received and dealt should not be seen as complete
            since it's not been tested properly.
        ]]
        -- GetHeroDamageTaken returns 0 always???
        local dmg_taken_from_hero = PlayerResource:GetHeroDamageTaken(player_id, true)
        local dmg_taken_from_creep = PlayerResource:GetCreepDamageTaken(player_id, true)
        local dmg_taken_from_struct = PlayerResource:GetTowerDamageTaken(player_id, true)
        local total_dmg_taken = dmg_taken_from_hero + dmg_taken_from_creep + dmg_taken_from_struct

        -- GetRawPlayerDamage seems to return the total damage done specifically to enemy heroes.
        local damage_done_to_heroes = PlayerResource:GetRawPlayerDamage(player_id)

        -- Don't know how to collect these.
        local damage_done_to_struct = 0.0
        local damage_done_to_creeps = 0.0
        local total_damage_dealt = 0.0

        fields[(i - 1) .. "_id"] = player_id
        fields[(i - 1) .. "_team"] = team
        fields[(i - 1) .. "_name"] = hero:GetName()
        fields[(i - 1) .. "_gold"] = hero:GetGold()
        fields[(i - 1) .. "_level"] = hero:GetLevel()
        fields[(i - 1) .. "_dmg_dealt_hero"] = damage_done_to_heroes
        fields[(i - 1) .. "_dmg_dealt_struct"] = damage_done_to_struct
        fields[(i - 1) .. "_dmg_dealt_creep"] = damage_done_to_creeps
        fields[(i - 1) .. "_total_dmg_dealt"] = total_damage_dealt
        fields[(i - 1) .. "_dmg_received_hero"] = dmg_taken_from_hero
        fields[(i - 1) .. "_dmg_received_struct"] = dmg_taken_from_struct
        fields[(i - 1) .. "_dmg_received_creep"] = dmg_taken_from_creep
        fields[(i - 1) .. "_total_dmg_received"] = total_dmg_taken
        fields[(i - 1) .. "_last_hits"] = hero:GetLastHits()
        fields[(i - 1) .. "_kills"] = hero:GetKills()
        fields[(i - 1) .. "_deaths"] = hero:GetDeaths()
        fields[(i - 1) .. "_assists"] = hero:GetAssists()
        fields[(i - 1) .. "_denies"] = hero:GetDenies()
    end

    stats["fields"] = fields

    return stats
end

---@param statistics table to be sent to the server.
function Statistics:Send_statistics(statistics)
    local route = "http://localhost:8080/api/statistics"
    local body = package.loaded["game/dkjson"].encode(statistics)

    local request = CreateHTTPRequestScriptVM("POST", route)
    request:SetHTTPRequestHeaderValue("Accept", "application/json")
    request:SetHTTPRequestRawPostBody("application/json", body)
    request:Send(
        ---@param result table
        function(result)
            -- currently ignoring response.
        end
    )
end


return Statistics