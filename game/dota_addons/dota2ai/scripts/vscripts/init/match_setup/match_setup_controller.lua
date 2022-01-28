-- imports
local Match_setup = require "init.match_setup.match_setup"



-- Match_setup_controller
local Match_setup_controller = {}



-- Populate game with bots.
function Match_setup_controller:Populate_game()
    Match_setup:Populate_game()
end

function Match_setup_controller:Force_game_start()
    Match_setup:Force_game_start()
end

function Match_setup_controller:Initialize_match_setup()
    Match_setup:Run()
end



return Match_setup_controller