local application
local time = {}

function time.sync()
    sntp.sync("0.ua.pool.ntp.org", function(sec, msec, server)
        rtctime.set(sec, msec)

        now = time.getTime()
        print(string.format("TIME NOW: %02d:%02d:%02d", now.hour, now.minute, now.second))
    end)
end

function time.getTime()
    local epoch = rtctime.get()

    local value = {
        hour = math.floor(epoch % 86400 / 3600 + 3),
        minute = math.floor(epoch % 3600 / 60),
        second = math.floor(epoch % 60),
        epoch = epoch
    }
    value.millis = time.toMillis(value.hour, value.minute)

    return value
end

function time.toMillis(hour, minute)
    return hour * 60 * 60 * 1000 + minute * 60 * 1000
end

function time.values()
    return {
        name = "time",
        title = "Time",
        value = time.getTime()
    }
end

return function (app)
    application = app
    application.on("modulesloaded", function ()
        app.modules.internet.on('appeared', time.sync)

        tmr.alarm(app.config.props.timers.time.id, app.config.props.timers.time.interval, tmr.ALARM_AUTO, time.sync)
    end)

    return time
end