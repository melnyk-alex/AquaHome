local application
local astro = {
    api = {
        astronomy = "http://api.wunderground.com/api/6723a9f9aa2d43e1/astronomy/q/Ukraine/Kyiv.json",
        weather = ""
    },
    data = {
        sunrise = { hour = 6, minute = 0 },
        sunset = { hour = 20, minute = 0 },
        moonrise = { hour = 20, minute = 0 },
        moonset = { hour = 6, minute = 0 }
    }
}

function astro.sync(callback)
    http.get(astro.api.astronomy, nil, function(code, data)
        if code == 200 then
            local data_table = cjson.decode(data)

            astro.data = {
                sunrise = {
                    hour = tonumber(data_table.sun_phase.sunrise.hour),
                    minute = tonumber(data_table.sun_phase.sunrise.minute)
                },
                sunset = {
                    hour = tonumber(data_table.sun_phase.sunset.hour),
                    minute = tonumber(data_table.sun_phase.sunset.minute)
                },
                moonrise = {
                    hour = tonumber(data_table.moon_phase.moonrise.hour),
                    minute = tonumber(data_table.moon_phase.moonrise.minute)
                },
                moonset = {
                    hour = tonumber(data_table.moon_phase.moonset.hour),
                    minute = tonumber(data_table.moon_phase.moonset.minute)
                }
            }

            if callback ~= nil then
                callback(astro)
            end
        end
    end)
end

function astro.values()
    return {
        astro = astro.data
    }
end

return function(app)
    application = app
    return astro
end