local application
local web = {
    server = nil,
    opened = false,
    jsonprops = ""
}

function web.handler(conn)
    conn:on("receive", function(sock, data)
        ok, json = pcall(cjson.encode, application.config.props)
        if ok then
            web.jsonprops = json
        end

        filename = string.match(data, "GET /(.*) HTTP")
        filename = filename == "" and "index.html" or filename

        if file.exists(filename) then
            file.open(filename, "r")
            opened = true
            sock:send("HTTP/1.1 200 OK\r\nServer: AquaHome on ESP8266\r\nContent-Type: text/html\r\n\r\n")
        else
            sock:send("HTTP/1.1 404 OK\r\nServer: AquaHome on ESP8266\r\nContent-Type: text/html\r\n\r\n")
        end
    end)

    local send = function(sock)
        if opened then
            local line = file.readline()

            if line ~= nil then
                local wrapped = string.gsub(line, "var config = {};", "var config = " .. web.jsonprops .. ";")

                sock:send(wrapped)
            else
                file.close()
                opened = false
            end
        end

        if not opened then
            sock:close()
        end
    end

    conn:on("sent", send)
end

return function(app)
    application = app
    web.server = net.createServer(net.TCP, 5)
    web.server:listen(80, web.handler)

    return web
end