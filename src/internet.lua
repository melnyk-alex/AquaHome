local application
local internet = {}
internet.listeners = {}
internet.listeners.appeared = {}

local apcheck = 1

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
        apcheck = apcheck + 1

        local info = application.config.props.wifi[apcheck]

        if info ~= nil then
            internet.connect(info)
        end
    end
end

function internet.connect(info)
    print("TRY CONNECT AP", info.ssid)
    wifi.sta.config(info.ssid, info.pass, 1)
end

return function(app)
    application = app

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, internet.gotIP)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, internet.disconnected)
    wifi.setmode(wifi.STATION)

    local info = application.config.props.wifi[apcheck]

    if info ~= nil then
        internet.connect(info)
    end

    return internet
end