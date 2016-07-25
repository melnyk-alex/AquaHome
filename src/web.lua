local web = {
    server = nil,
    opened = false,
    init = function()
        web.server = net.createServer(net.TCP, 5)
        web.server:listen(80, web.handler)
    end,
    handler = function(conn)
        conn:on("receive", function(sock, data)
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
                    ok, json = pcall(cjson.encode, {})
                    if ok then
                        line = string.gsub(line, "JS", "var data = " .. json .. ";")
                    end

                    sock:send(line)
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
}

return web