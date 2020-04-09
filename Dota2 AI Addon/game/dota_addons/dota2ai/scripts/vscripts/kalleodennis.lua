Dota2AI.selectedHeroes = {}

function Dota2AI:GetRandomHero()
    local hero = Dota2AI.sHeroSelection[math.random(#Dota2AI.sHeroSelection)]
    if has_value(Dota2AI.selectedHeroes, hero) then
        return Dota2AI:GetRandomHero()
    else
        table.insert(Dota2AI.selectedHeroes, hero)
        return hero
    end
end

function Dota2AI:HeroSelection()
    SendToServerConsole("dota_create_fake_clients")
    request = CreateHTTPRequestScriptVM("GET", "http://localhost:8080/api/party")
    request:Send(
        function(result)
            local data = package.loaded["game/dkjson"].decode(result["Body"])
            for i, hero in pairs(data) do
                table.insert(Dota2AI.selectedHeroes, hero)
                local playerID = i - 1
                PlayerResource:SetCustomTeamAssignment(playerID, DOTA_TEAM_FIRST)
                Timers:CreateTimer(
                    "assign_player_" .. playerID,
                    {
                        endTime = Time() + 1,
                        callback = function()
                            PlayerResource:GetPlayer(playerID):SetSelectedHero(hero)
                            if i > 1 then
                                SendToServerConsole("kickid " .. i)
                            end
                        end
                    }
                )
            end

            Timers:CreateTimer(
                function()
                    local currentState = GameRules:State_Get()
                    if currentState ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
                        return 1.0
                    end

                    Tutorial:AddBot(Dota2AI:GetRandomHero(), "mid", "easy", false)
                    Tutorial:AddBot(Dota2AI:GetRandomHero(), "top", "easy", false)
                    Tutorial:AddBot(Dota2AI:GetRandomHero(), "top", "easy", false)
                    Tutorial:AddBot(Dota2AI:GetRandomHero(), "bot", "easy", false)
                    Tutorial:AddBot(Dota2AI:GetRandomHero(), "bot", "easy", false)
                    -- TODO: Make this dynamic again.....
                    -- for i = 1, TableLength(data) do
                    --     Tutorial:AddBot(Dota2AI:GetRandomHero(), "mid", "easy", false)
                    -- end
                end
            )
        end
    )
end

function Dota2AI:APIRegisterHeroes(body)
    request = CreateHTTPRequestScriptVM("POST", "http://localhost:8080/api/register_heroes")
    request:SetHTTPRequestHeaderValue("Accept", "application/json")
    request:SetHTTPRequestHeaderValue("X-Jersey-Tracing-Threshold", "VERBOSE")
    request:SetHTTPRequestRawPostBody("application/json", body)
    request:Send(
        function(result)
            if result["StatusCode"] == 200 then
                --TODO what to do actually?
            else
                Dota2AI.Error = true
                for k, v in pairs(result) do
                    Warning(string.format("%s : %s\n", k, v))
                end
                Warning("Request was:")
                Warning(body)
            end
        end
    )
end

function Dota2AI:BotThinking(hero, heroEntities)
    Dota2AI:Update(hero)
    if self._Error == true then
        return 0
    else
        return 0.33
    end
end

function Dota2AI:Update(hero)
    local world = Dota2AI:JSONWorld(hero)
    local heroes = Dota2AI:JSONGetGoodGuys(hero)
    local body = package.loaded["game/dkjson"].encode({["heroes"] = heroes, ["world"] = world})

    request = CreateHTTPRequestScriptVM("POST", "http://localhost:8080/api/update")
    request:SetHTTPRequestHeaderValue("Accept", "application/json")
    request:SetHTTPRequestHeaderValue("X-Jersey-Tracing-Threshold", "VERBOSE")
    request:SetHTTPRequestRawPostBody("application/json", body)
    request:Send(
        function(result)
            if result["StatusCode"] == 200 then

                Dota2AI:ParseActions(hero, result["Body"])
            else
                Dota2AI.Error = true
                for k, v in pairs(result) do
                    Warning(string.format("%s : %s\n", k, v))
                end
                Warning("Request was:")
                Warning(body)
            end
        end
    )
end

function Dota2AI:ParseActions(h, jsonresults)
    actions = package.loaded["game/dkjson"].decode(jsonresults)
    for strhero, cmd in pairs(actions) do
        local hero = Dota2AI:GetGoodGuy(h, strhero)
        if hero == nil then
            Warning("Could not find hero with name: " .. strhero)
        else
            Dota2AI:ParseHeroCommand(hero, cmd)
        end
    end
end
