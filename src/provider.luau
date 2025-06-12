--!strict
local types = require("./types")
local util = require("./util")
local modding = require("./modding")
local constants = require("./constants")
local provider = {}

function provider.createProvider<T>(provider: types.DynamicTable<T>): T
    return modding.createProvider(provider)
end

function provider.register<T>(provider: types.Provider<T>, name: string?): T
    util.assert( provider._type == "provider", constants.errors.invalidProviderType, "provider", provider._type, provider._name )
    util.assert( not modding.isProviderRegistered(provider), constants.errors.providerAlreadyRegistered, provider._name )
    util.assert( name == nil or not modding.isSingletonRegistered(name), constants.errors.singletonAlreadyRegistered, name )

    local registeredProvider: types.RegisteredProvider<T> = provider
    registeredProvider._name = name
    registeredProvider._priority = registeredProvider._priority or 1
    registeredProvider._type = "registeredProvider"

    if name ~= nil then
        modding.registerSingleton(name, registeredProvider)
    else
        modding.registerProvider(registeredProvider)
    end
    return registeredProvider
end

function provider.use<T>(provider: types.RegisteredProvider<T>): T
	util.assert( provider._type == "registeredProvider", constants.errors.invalidProviderType, "provider", provider._type, provider._name )
    return provider
end

return provider
