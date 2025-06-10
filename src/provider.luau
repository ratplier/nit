--!strict
local types = require("./types")
local modding = require("./modding")
local provider = {}

function provider.create<T>(provider: types.DynamicTable<T>): types.Provider<T>
    provider._type = "provider"
    return provider
end

function provider.register<T>(provider: types.Provider<T>, name: string?): types.RegisteredProvider<T>
    assert(provider._type == "provider", "provider is of invalid type")
    assert(name == nil or modding.singletonExists(name), "singleton already exists")

    local registeredProvider: types.RegisteredProvider<T> = provider
    registeredProvider._name = name
    registeredProvider._priority = registeredProvider._priority or 1
    registeredProvider._type = "registeredProvider"

    if name ~= nil then
        modding.mountSingleton(name, registeredProvider)
    end

    modding.registerProvider(registeredProvider)
    return registeredProvider
end

return provider