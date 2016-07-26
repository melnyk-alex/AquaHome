local application
local astro = {
    api = {
        astronomy = "http://api.wunderground.com/api/6723a9f9aa2d43e1/astronomy/q/Ukraine/Kyiv.json",
        weather = ""
    },
    data = {
        sunrise = { hour = 6, minute = 0, millis = 21600000 },
        sunset = { hour = 20, minute = 0, millis = 72000000 },
        moonset = { hour = 6, minute = 0, millis = 21600000 }
    }
}

function astro.sync()
    http.get(astro.api.astronomy, nil, function(code, data)
        if code == 200 then
            local data_table = cjson.decode(data)

            astro.data = {}

            local astroData = {
                sunrise = data_table.sun_phase.sunrise,
                sunset = data_table.sun_phase.sunset,
                moonset = data_table.moon_phase.moonset
            }

            for name, when in pairs(astroData) do
                astro.data[name] = {
                    hour = when.hour,
                    time = when.minute,
                    millis = application.modules.time.toMillis(when.hour, when.minute)
                }
            end
        end
    end)
end

function astro.values()
    return {
        name = "astro",
        title = "Astronomy",
        value = astro.data
    }
end

return function(app)
    application = app
    application.on("modulesloaded", function()
        app.modules.internet.on('appeared', astro.sync)

        tmr.alarm(app.config.props.timers.astro.id, app.config.props.timers.astro.interval, tmr.ALARM_AUTO, astro.sync)
    end)

    return astro
end