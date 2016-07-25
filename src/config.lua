local config = {
    filename = "config.json",
    props = {}
}

function config.load()
    print("LOAD CONFIG", config.filename)
    if not file.exists(config.filename) then
        return
    end

    local json = ""
    file.open(config.filename, "r")

    while true do
        local rline = file.readline()

        if not rline then file.close() break end

        json = json .. rline
    end

    local ok, decoded = pcall(cjson.decode, json)
    config.props = ok and decoded or {}
end

function config.save()
    file.open(config.filename, "w+")
    file.write(cjson.encode(config.props))
    file.close()
end

return function()
    config.load()
    return config
end