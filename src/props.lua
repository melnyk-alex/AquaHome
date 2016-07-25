local props = {
    wifiw = {
        ssid = "Alpha 2.4G",
        pass = "codefire",
    },
    wifih = {
        ssid = "Beta",
        pass = "Intel1394"
    },
    timers = {
        time = { id = 1, interval = 3600000 },
        astro = { id = 2, interval = 3600000 },
        light = { id = 3, interval = 1000 * 15 },
        trans = { id = 4, interval = 1 }
    },

}

return props