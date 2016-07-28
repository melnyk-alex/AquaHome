local application
local light = {
    const = { min = 0, max = 1023 },
    leds = {
        r = { pin = 1, bright = 0 },
        g = { pin = 2, bright = 0 },
        b = { pin = 3, bright = 0 },
        c = { pin = 4, bright = 0 },
        h = { pin = 5, bright = 0 }
    },
    bright = {
        moon = 0,
        day = 100,
        curr = 0
    }
}

function light.sync()
    local current, sunrise, sunset = application.modules.time.getTime().millis, application.modules.astro.data.sunrise.millis, application.modules.astro.data.sunset.millis

    local daylight, absolute = sunset - sunrise, current - sunrise
    local percent = absolute * 100. / daylight
    -- 0 -> 100 -> 0
    local lightvalue = (50 - math.abs(percent - 50) * 100 / 50)

    if sunrise <= current and current <= sunset then
        light.bright.curr = math.floor(lightvalue)

        print(sunrise, current, sunset)
        print(daylight, absolute, percent)
        print(lightvalue, math.floor(lightvalue))
        print("DAY")
    else
        light.bright.curr = 0
        print("MOON")
    end
end

function light.values()
    return {
        name = "light",
        title = "Light",
        value = {
            bright = light.bright
        }
    }
end

return function(app)
    application = app

    for i, pin in pairs({ light.leds.b.pin, light.leds.c.pin, light.leds.h.pin }) do
        pwm.setup(pin, 100, 0)
        pwm.start(pin)
    end

    application.on("modulesloaded", function()
        light.sync()

        tmr.alarm(app.config.props.timers.light.id, app.config.props.timers.light.interval, tmr.ALARM_AUTO, light.sync)
    end)

    return light
end