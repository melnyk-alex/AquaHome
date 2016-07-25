local time = {}

function time.sync()
    sntp.sync("0.ua.pool.ntp.org", function(sec, msec, server)
        rtctime.set(sec, msec)
        print("TIME SYNC")
    end)
end

function time.getTime()
    local sec = rtctime.get()
    return {
        hour = math.floor(sec % 86400 / 3600 + 3),
        minute = math.floor(sec % 3600 / 60),
        second = math.floor(sec % 60)
    }
end

return function (app)
    app.modules.internet.on('appeared', time.sync)
    return time
end