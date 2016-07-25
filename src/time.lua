local time = {
    sync = function(callback)
        sntp.sync("0.ua.pool.ntp.org", function(sec, msec, server)
            rtctime.set(sec, msec)

            if callback ~= nil then
                callback(time.getTime())
            end
        end)
    end,
    getTime = function()
        local sec = rtctime.get()
        return {
            hour = math.floor(sec % 86400 / 3600 + 3),
            minute = math.floor(sec % 3600 / 60),
            second = math.floor(sec % 60)
        }
    end
}

return time