---@alias CDOTA_BaseNPC any
---@alias CDOTA_BaseNPC_Hero CDOTA_BaseNPC
---@alias CDOTABaseAbility any
---@alias CDOTA_Item CDOTABaseAbility

if Main_controller == nil then
    _G.Main_controller = class({})
end



-- imports
require "libraries.timers"
require "settings.settings"
require "main_controller"



-- Entry point. \
-- Run Addon after 1 second to ensure game has started.
function Activate()
    GameRules.Main_controller = Main_controller()
    Timers:CreateTimer({
        endTime = 1.0,
        callback = GameRules.Main_controller.Run
    })
end