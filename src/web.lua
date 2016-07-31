local application
local web = {
    server = nil,
    opened = false,
    rest = {
        GET = { "/values", "/astro", "/internet", "/light", "/time" },
        POST = { "/light" }
    },
    response = {
        OK = "HTTP/1.1 200 OK\r\nServer: AquaHome on ESP8266\r\nContent-Type: MIME\r\n\r\n",
        NOT_FOUND = "HTTP/1.1 404 OK\r\nServer: AquaHome on ESP8266\r\nContent-Type: text/plain\r\n\r\nNOT FOUND!"
    }
}

function web.handler(conn)
    local send = function(sock)
        if opened then
            local line = file.readline()

            if line ~= nil then
                line = string.gsub(line, "var config = {};", "var config = " .. web.jsonconfig .. ";")
                line = string.gsub(line, "var values = {};", "var values = " .. web.jsonvalues .. ";")

                sock:send(line)
            else
                web.jsonconfig = nil
                web.jsonvalues = nil

                file.close()
                opened = false
            end
        end

        if not opened then
            sock:close()
            collectgarbage()
        end
    end

    conn:on("sent", send)
    conn:on("receive", function(sock, request)
        local method, path, query = string.match(request, "([A-Z]+) ([^?]+)(.*) HTTP/1.1")
        local filename = string.gsub(path, "^/", "")
        filename = filename == "" and "index.html" or filename

        local handled = false

        if file.exists(filename) then
            local ok, json = pcall(cjson.encode, application.config.props)
            if ok then
                web.jsonconfig = json
            end
            ok, json = pcall(cjson.encode, application.getValues())
            if ok then
                web.jsonvalues = json
            end

            handled = true
            file.open(filename, "r")
            opened = true

            sock:send(string.gsub(web.response.OK, "MIME", "text/html"))
        elseif web.rest[method] ~= nil then
            for idx, pname in pairs(web.rest[method]) do
                if pname == path then
                    handled = web.doRest(sock, method, path)
                    break
                end
            end
        end

        if not handled then
            sock:send(web.response.NOT_FOUND)
        end
    end)
end

function web.doRest(sock, method, path)
    local result = true

    if method == "GET" then
        if path == "/values" then
            sock:send(string.gsub(web.response.OK, "MIME", "application/json") .. cjson.encode(application.getValues()))
        else
            local values = application.getValues()[string.gsub(path, "^/", "")]
            if values ~= nil then
                sock:send(string.gsub(web.response.OK, "MIME", "application/json") .. cjson.encode(values))
            else
                result = false
            end
        end
    elseif method == "POST" then
        result = false
    end

    return result
end

return function(app)
    application = app

    application.on("modulesloaded", function()
        web.server = net.createServer(net.TCP, 5)
        web.server:listen(80, web.handler)
    end)

    return web
end