local internet = {}
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

return function(app)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, internet.gotIP)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(app.config.props.wifi.ssid, app.config.props.wifi.pass, 1)

    return internet
end