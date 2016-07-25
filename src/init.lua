print("...WAITING...")

tmr.alarm(0, 6000, tmr.ALARM_SINGLE, function ()
    local cfg = dofile("config.lua")
    config = cfg()
    print(config, cjson.encode(config.props))

    if status then
        print("CONFIG LOADED")
    else
        print(status, config)
    end

--    if pcall(dofile("app.lua"), config) then
--        print("APP IS DONE LOADED")
--    else
--        print("ERRORS")
--    end
end)