-- Here are the event trigger that are called by the game on certain occasions asynchronously to the game's ticks

--------------------------------------------------------------------------------
-- GameEvent:OnGameRulesStateChange
--
-- Handles the game state cycles. Not much to do here yet
--
--------------------------------------------------------------------------------
function Dota2AI:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()
    if nNewState == DOTA_GAMERULES_STATE_INIT then
        self:Reset()
    elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        self.HeroSelection()
        print("OnGameRulesStateChange: Hero Selection")
    elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        print("OnGameRulesStateChange: Pre Game Selection")
        SendToServerConsole("dota_dev forcegamestart") -- Skip the draft process
    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        print("OnGameRulesStateChange: Game In Progress")
        Timers:CreateTimer({
                endTime = 0.5,
                callback = function()
                    -- check if we can acess the hero entities
                    local heroEntity = PlayerResource:GetSelectedHeroEntity(0)
                    if heroEntity == nil then
                        return 0.5
                    end
                    local heroes = Dota2AI:GetGoodGuys(heroEntity)
                    if TableLength(heroes) ~= 5 then
                        return 0.5
                    end
                    Dota2AI:OnHeroPicked(heroEntity, heroes)
                    -- local c = 2
                    -- while c <= TableLength(heroes) do
                    --     SendToServerConsole("kickid " .. c)
                    --     c = c + 1
                    -- end
                end
        })
    end
end

--------------------------------------------------------------------------------
-- GameEvent:OnHeroPicked
--
-- Once a hero is picked, a "context think function" is set that make makes a web call every time it's called
--------------------------------------------------------------------------------

function Dota2AI:OnHeroPicked(heroEntity, heroes)
    local jsonHeroes = {}
    heroEntity:SetContextThink(
        "Dota2AI:BotThinking",
        function()
            return Dota2AI:BotThinking(heroEntity, heroes)
        end,
        0.33
    )
    for i, hero in pairs(heroes) do
        jsonHeroes[i] = Dota2AI:JSONunit(hero)
    end
    Dota2AI:APIRegisterHeroes(package.loaded["game/dkjson"].encode(jsonHeroes))
    Say(nil, "Bot (team = " .. heroEntity:GetTeam() .. ", user=0 picked " .. heroEntity:GetName(), false)
end

--FIXME
--function Dota2AI:Reset()
--request = CreateHTTPRequestScriptVM( "POST", Dota2AI.baseURL .. "/reset")
--request:SetHTTPRequestRawPostBody('application/json', "")
--end

--------------------------------------------------------------------------------
-- GameEvent:OnHeroLevelUp
--
-- When a hero levels up, this function makes a web call to check which ability should be levelled
--------------------------------------------------------------------------------
function Dota2AI:OnHeroLevelUp(event)
    local userid = event.player
    local heroindex = event.heroindex
    local class = event.hero
    local heroEntity = EntIndexToHScript(heroindex)

    -- only make a web call if it's the controlled hero. Dota2AI:OnHeroLevelUp is also called for other heroes
    if userid == 0 then
        self:BotLevelUp(heroEntity)
    end
end

-- Helper function for Dota2AI:OnHeroLevelUp
function Dota2AI:BotLevelUp(heroEntity)
    request = CreateHTTPRequestScriptVM("POST", Dota2AI.baseURL .. "/levelup")
    request:SetHTTPRequestHeaderValue("Accept", "application/json")
    request:SetHTTPRequestHeaderValue("Content-Length", "0")
    request:Send(
        function(result)
            if result["StatusCode"] == 200 then
                self:ParseHeroLevelUp(heroEntity, result["Body"])
            else
                Dota2AI.Error = true
                for k, v in pairs(result) do
                    Warning(string.format("%s : %s\n", k, v))
                end
            end
        end
    )
end

--------------------------------------------------------------------------------
-- GameEvent:OnPlayerChat
--
-- This function doesn't do anything except forwarding chat messages of other players to the bot.
-- I used it to control my test implementation, i.e. "bot go", "bot retreat", "bot attack" as simple chat commands
--------------------------------------------------------------------------------
function Dota2AI:OnPlayerChat(event)
    request = CreateHTTPRequestScriptVM("POST", "http://localhost:8080/api/chat")
    request:SetHTTPRequestHeaderValue("Accept", "application/json")
    request:SetHTTPRequestHeaderValue("X-Jersey-Tracing-Threshold", "VERBOSE")
    request:SetHTTPRequestRawPostBody("application/json", self:JSONChat(event))
    request:Send(
        function(result)
            if result["StatusCode"] == 200 then
            else
                Dota2AI.Error = true
                for k, v in pairs(result) do
                    Warning(string.format("%s : %s\n", k, v))
                end
                Warning("Request was:")
                Warning(self:JSONChat(event))
            end
        end
    )
end

function Dota2AI:OnBaseURLChanged(event)
    Dota2AI.baseURL = CustomNetTables:GetTableValue("game_state", "base_url")["value"]
    print("New base URL " .. Dota2AI.baseURL)
end
