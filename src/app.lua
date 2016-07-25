local app = {}
app.config = {}
app.listeners = {}
app.listeners.modulesloaded = {}
app.modules = {}

function app.init(conf)
    app.config = conf and conf or {}
    local status, error = pcall(app.loadModules)

    if status then
        print("MODULES LOADED")

        app.modules.internet.on('appeared', function (i)
            print("IP:" .. i.IP)
        end)

        for i,callback in pairs(app.listeners.modulesloaded) do
            status, error = pcall(callback, app)

            if not status then
                print(error)
            end
        end
    else
        print("app", "ERROR MODULES LOAD", error)
    end

    --    print("WAKEUP WIFI")
    --    wifi.setmode(wifi.STATION)
    --    wifi.sta.config(config.data.wifiw.ssid, config.data.wifiw.pass, 1)

    --    local function wifi_connect()
    --        if wifi.sta.getip() ~= nil then
    --            tmr.stop(0)
    --
    --            time.sync(function(now)
    --                print(string.format("NOW: %02d:%02d:%02d", now.hour, now.minute, now.second))
    --            end)
    --
    --            print("IP: " .. wifi.sta.getip())
    --        end
    --    end
    --
    --    local function ledssync()
    --        now = time.getTime()
    --
    --        if (now.hour == astro.data.sunrise.hour and now.minute >= astro.data.sunrise.minute) or
    --                (now.hour > astro.data.sunrise.hour and now.hour < astro.data.sunset.hour) or
    --                (now.hour == astro.data.sunset.hour and now.minute <= astro.data.sunset.minute) then
    --            if light.phase.curr ~= "sun" then
    --                light.phase = { last = light.phase.curr, curr = "sun" }
    --            end
    --        elseif (now.hour == astro.data.moonrise.hour and now.minute >= astro.data.moonrise.minute) or
    --                (now.hour > astro.data.moonrise.hour or now.hour < astro.data.moonset.hour) or
    --                (now.hour == astro.data.moonset.hour and now.minute <= astro.data.moonset.minute) then
    --            if light.phase.curr ~= "moon" then
    --                light.phase = { last = light.phase.curr, curr = "moon" }
    --            end
    --        elseif light.phase.curr ~= "night" then
    --            light.phase = { last = light.phase.curr, curr = "night" }
    --        end
    --
    --        tmr.unregister(props.timers.trans.id)
    --        tmr.alarm(props.timers.trans.id, props.timers.trans.interval, tmr.ALARM_SINGLE, check)
    --    end
    --
    --    local function check()
    --        if light.phase.last ~= light.phase.curr then
    --            print(light.phase.last, "->", light.phase.curr)
    --
    --            light.phase.last = light.phase.curr
    --
    --            if light.phase.curr == "sun" then
    --                light.transition.day()
    --            elseif light.phase.curr == "moon" then
    --                light.transition.moon()
    --            else
    --                light.transition.night()
    --            end
    --        end
    --    end
end

function app.loadModules()
    print("LOAD MODULES:", cjson.encode(app.config.props.modules))
    for i, name in pairs(app.config.props.modules) do
        print("LOAD MODULE:", name)
        local status, module = pcall(dofile, name .. ".lua")

        if status then
            -- CALL MODULE INIT FUNCTION
            status, module = pcall(module, app)

            if status then
                app.modules[name] = module
            else
                print("app", "ERROR INIT MODULE", name, module)
            end
        else
            print("app", "ERROR LOAD MODULE", name, module)
        end
    end
end

function app.on(event, callback)
    if event == "modulesloaded" then
        table.insert(app.listeners.modulesloaded, callback)
    else
        print("EVENT DOESN'T EXISTS", event)
    end
end

--tmr.alarm(0, 500, tmr.ALARM_AUTO, wifi_connect)
--tmr.alarm(props.timers.time.id, props.timers.time.interval, tmr.ALARM_AUTO, time.sync)
--tmr.alarm(props.timers.astro.id, props.timers.astro.interval, tmr.ALARM_AUTO, astro.sync)
--tmr.alarm(props.timers.light.id, props.timers.light.interval, tmr.ALARM_AUTO, ledssync)

return app.init