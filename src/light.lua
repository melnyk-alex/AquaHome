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
        day = 960,
        moon = { b = 60, c = 15, h = 25 },
        night = 0
    },
    phase = { last = "", curr = "" },
    transition = {
        day = function()
            print("DAY MODE")
            for i = 0, light.const.max do
                light.leds.b.bright = light.leds.b.bright > light.const.min and light.leds.b.bright - 1 or light.const.min
                light.leds.c.bright = light.leds.c.bright < light.bright.day and light.leds.c.bright + 1 or light.bright.day
                light.leds.h.bright = light.leds.h.bright < light.bright.day and light.leds.h.bright + 1 or light.bright.day

                pwm.setduty(light.leds.b.pin, light.leds.b.bright)
                pwm.setduty(light.leds.c.pin, light.leds.c.bright)
                pwm.setduty(light.leds.h.pin, light.leds.h.bright)

                tmr.delay(50)
            end
            print(light.leds.b.bright, light.leds.c.bright, light.leds.h.bright)
        end,
        moon = function()
            print("MOON MODE")
            for i = 0, light.const.max do
                light.leds.b.bright = light.leds.b.bright < light.bright.moon.b and light.leds.b.bright + 1 or light.bright.moon.b
                light.leds.c.bright = light.leds.c.bright > light.bright.moon.c and light.leds.c.bright - 1 or light.bright.moon.c
                light.leds.h.bright = light.leds.h.bright > light.bright.moon.h and light.leds.h.bright - 1 or light.bright.moon.h

                pwm.setduty(light.leds.b.pin, light.leds.b.bright)
                pwm.setduty(light.leds.c.pin, light.leds.c.bright)
                pwm.setduty(light.leds.h.pin, light.leds.h.bright)

                tmr.delay(50)
            end
            print(light.leds.b.bright, light.leds.c.bright, light.leds.h.bright)
        end,
        night = function()
            print("NIGHT MODE")
            for i = 0, light.const.max do
                light.leds.b.bright = light.leds.b.bright > light.const.min and light.leds.b.bright - 1 or light.bright.night
                light.leds.c.bright = light.leds.c.bright > light.const.min and light.leds.c.bright - 1 or light.bright.night
                light.leds.h.bright = light.leds.h.bright > light.const.min and light.leds.h.bright - 1 or light.bright.night

                pwm.setduty(light.leds.b.pin, light.leds.b.bright)
                pwm.setduty(light.leds.c.pin, light.leds.c.bright)
                pwm.setduty(light.leds.h.pin, light.leds.h.bright)

                tmr.delay(50)
            end
            print(light.leds.b.bright, light.leds.c.bright, light.leds.h.bright)
        end
    }
}

return function()
    for i, pin in pairs({ light.leds.b.pin, light.leds.c.pin, light.leds.h.pin }) do
        pwm.setup(pin, 100, 0)
        pwm.start(pin)
    end

    return light
end