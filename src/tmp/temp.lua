data = {
    sunrise = {
        hour = 5,
        minute = 0
    },
    sunset = {
        hour = 19,
        minute = 0
    }
}

print("LOAD MODULES")

props = dofile("props.lua")
light = dofile("light.lua")
time = dofile("time.lua")
astro = dofile("astro.lua")

light.init()

print("WAKEUP WIFI...")

wifi.setmode(wifi.STATION)
wifi.sta.config(props.wifiw.ssid, props.wifiw.pass, 1)
--wifi.sta.connect()

function wifi_connect()
    if wifi.sta.getip() ~= nil then
        tmr.stop(0)

        print("IP: " .. wifi.sta.getip())

        synchronize()
    end
end

function synchronize()
    time.syncTime(function(time)
        astro.getAstronomy(function(dt)
            data = dt

            printAstronomy()
            check_state()
        end)
    end)
end

function printAstronomy()
    ts = time.getTime(rtctime.get())

    print("\nTime is now\n" .. ts.hour .. ":" .. ts.minute .. ":" .. ts.second)
    print("Sunrise: " .. data.sunrise.hour .. ":" .. data.sunrise.minute)
    print("Sunset: " .. data.sunset.hour .. ":" .. data.sunset.minute)
end

function check_state()
    local ts = time.getTime(rtctime.get())

    if ts.hour >= data.sunrise.hour and ts.hour < data.sunset.hour then
        light.phase.curr = "day"
    else
        light.phase.curr = "night"
    end

    if light.phase.curr ~= light.phase.last then
        light.phase.last = light.phase.curr

        tmr.unregister(3)

        tmr.alarm(3, 1, tmr.ALARM_SINGLE, function()
            if light.phase.curr == "day" then
                nightToDay()
            else
                dayToNight()
            end
        end)
    end
end

function nightToDay()
    --    pwm.setduty(light.color.b, light.night.max)
    --    pwm.setduty(light.white.h, 0)
    --    pwm.setduty(light.white.c, 0)

    tmr.delay(1000 * 1000 * 3)

    for i = 0, 1023 do
        pwm.setduty(light.color.b, light.night.max - i > 0 and light.night.max - i or 0)
        pwm.setduty(light.white.c, i < light.day.max and i or light.day.max)
        pwm.setduty(light.white.h, i < light.day.max and i or light.day.max)
        tmr.delay(1000)
    end
end

function dayToNight()
    --    pwm.setduty(light.color.b, 0)
    --    pwm.setduty(light.white.h, light.day.max)
    --    pwm.setduty(light.white.c, light.day.max)

    tmr.delay(1000 * 1000 * 3)

    cb = pwm.getduty(light.color.b)
    wc = pwm.getduty(light.white.c)
    wh = pwm.getduty(light.white.h)

    for i = 0, 1023 do
        cb = cb < light.night.max and cb + 1 or light.night.max
        wc = wc < light.day.max and wc + 1 or light.day.max
        wh = wh < light.day.max and wh + 1 or light.day.max

        pwm.setduty(light.color.b, cb)
        pwm.setduty(light.white.c, light.day.max - wc)
        pwm.setduty(light.white.h, light.day.max - wh)

        tmr.delay(1000)
    end
end

--check_state()

--tmr.alarm(0, 1000, tmr.ALARM_AUTO, wifi_connect)
--tmr.alarm(1, 10000, tmr.ALARM_AUTO, check_state)
--tmr.alarm(2, 1000 * 3600, tmr.ALARM_AUTO, synchronize)
