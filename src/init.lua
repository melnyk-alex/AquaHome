print("...WAITING...")

tmr.alarm(0, 6000, tmr.ALARM_SINGLE, function()
    node.setcpufreq(node.CPU160MHZ)

    local status, config = pcall(dofile, "config.lua")

    if status then
        status, config = pcall(config)

        if status then
            print("CONFIG LOADED")

            status, app = pcall(dofile, "app.lua")

            if status then
                status, app = pcall(app, config)

                if status then
                    print("APP LOADED")
                else
                    print(app)
                end
            else
                print(app)
            end
        else
            print(app)
        end
    else
        print(app)
    end
end)