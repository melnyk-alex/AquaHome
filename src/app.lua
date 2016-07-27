local app = {}
app.config = {}
app.listeners = {}
app.listeners.modulesloaded = {}
app.modules = {}

function app.init(conf)
    app.config = conf and conf or {}
    local status, error = pcall(app.loadModules)

    if status then
        print("MODULES LOADED")

        app.modules.internet.on('appeared', function (i)
            print("IP:" .. i.IP)
        end)

        for i,callback in pairs(app.listeners.modulesloaded) do
            status, error = pcall(callback, app)

            if not status then
                print(error)
            end
        end
    else
        print("app", "ERROR MODULES LOAD", error)
    end

    collectgarbage()
    print(node.heap())
end

function app.loadModules()
    print("LOAD MODULES:", cjson.encode(app.config.props.modules))
    for i, name in pairs(app.config.props.modules) do
        print("LOAD MODULE:", name)
        local status, module = pcall(dofile, name .. ".lua")

        if status then
            -- CALL MODULE INIT FUNCTION
            status, module = pcall(module, app)

            if status then
                app.modules[name] = module
            else
                print("app", "ERROR INIT MODULE", name, module)
            end
        else
            print("app", "ERROR LOAD MODULE", name, module)
        end
    end
end

function app.getValues()
    local values = {}

    for i, module in pairs(app.modules) do
        local status, data = pcall(module.values)

        if status then
            table.insert(values, data)
        end
    end

    return values
end

function app.on(event, callback)
    if event == "modulesloaded" then
        table.insert(app.listeners.modulesloaded, callback)
    else
        print("EVENT DOESN'T EXISTS", event)
    end
end

--tmr.alarm(0, 500, tmr.ALARM_AUTO, wifi_connect)

return app.init