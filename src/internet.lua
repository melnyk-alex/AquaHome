local application
local internet = {
    apcheck = 1,
    ssid = ""
}
internet.listeners = {}
internet.listeners.appeared = {}

function internet.on(event, callback)
    if event == "appeared" then
        table.insert(internet.listeners.appeared, callback)
    else
        print("internet", "EVENT DOESN'T EXISTS", event)
    end
end

function internet.gotIP(t)
    for i, callback in pairs(internet.listeners.appeared) do
        local status, error = pcall(callback, t)

        if not status then
            print(error)
        end
    end
end

function internet.disconnected(t)
    print("::: DISCONNECTED", t.SSID, t.BSSID, t.reason)

    if t.reason == 201 then
        internet.apcheck = internet.apcheck + 1

        internet.ssid = ""

        internet.connect()
    end
end

function internet.connect()
    local info = application.config.props.wifi[internet.apcheck]

    if info ~= nil then
        print("TRY CONNECT AP", info.ssid)

        internet.ssid = info.ssid
        wifi.sta.config(info.ssid, info.pass, 1)
    end
end

function internet.values()
    return {
        title = "Network",
        value = {
            ssid = internet.ssid
        }
    }
end

return function(app)
    application = app

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, internet.gotIP)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, internet.disconnected)
    wifi.setmode(wifi.STATION)

    internet.connect()

    return internet
end