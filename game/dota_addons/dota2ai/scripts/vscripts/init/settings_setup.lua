-- Settings_setup
local Settings_setup = {}

-- Request settings from server and put response into global table Settings.
function Settings_setup:Get_and_set_settings()
    ---@type table
    local request = CreateHTTPRequestScriptVM("GET", "http://localhost:8080/api/settings")
    request:Send(
        ---@param settings_json table
        function(settings_json)
            if settings_json["StatusCode"] == 406 then
                print("Request settings was Not Acceptable!")
                return
            end
            ---@type table
            local settings_data = package.loaded["game/dkjson"].decode(settings_json["Body"])
            for key, value in pairs(settings_data) do
                Settings[key] = value
            end
        end
    )
end

return Settings_setup