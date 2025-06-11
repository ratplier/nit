--!strict
local types = require("./types")
local modding = require("./modding")
local provider = {}

function provider.createProvider<T>(provider: types.DynamicTable<T>): types.Provider<T>
    return modding.createProvider(provider)
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

function provider.use<T>(provider: types.RegisteredProvider<T>): T
	assert(provider._type == "registeredProvider", "Cannot use an unregistered provider")
    return provider
end

return provider