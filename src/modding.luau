--!strict
local types = require("./types")
local util = require("./util")
local constants = require("./constants")

local internal = {
	events = {
		singletonRegistered = {} :: { types.Callback<types.RegisteredProvider> },
		providerRegistered = {} :: { types.Callback<types.RegisteredProvider> },
	},
    providers = {},
	singletons = {},
	errors = constants.errors,
}

local modding = {}

local function fireConcurrent<A...>(listeners: { types.Callback<A...> }, ...: A...)
	util.spawnCallbacks(listeners, ...)
end

function modding.registerSingleton(name: string, provider: types.RegisteredProvider)
	util.assert( provider._type == "registeredProvider", internal.errors.invalidProviderType, "registeredProvider", provider._type, provider._name )

	internal.singletons[name] = provider
	fireConcurrent(internal.events.singletonRegistered, provider)
end

function modding.getSingleton(name: string)
	return internal.singletons[name]
end

function modding.getSingletons()
	return internal.singletons
end

function modding.isSingletonRegistered(name: string)
	return internal.singletons[name] ~= nil
end

function modding.createProvider<T>(provider: types.DynamicTable<T>): types.Provider<T>
	provider._type = "provider"
	return provider
end

function modding.registerProvider<T>(provider: types.Provider<T>)
	util.assert( provider._type == "provider", internal.errors.invalidProviderType, "provider", provider._type, provider._name )

    internal.providers[provider._name] = provider
	fireConcurrent(internal.events.providerRegistered, provider)
end

function modding.isProviderRegistered(name: string)
    return internal.providers[name] ~= nil
end

function modding.getDependencies(provider: types.RegisteredProvider)
	local dependencies = {}
	for key, value in provider::any do
		if typeof(value) ~= "table" then continue end
		if value._type ~= "registeredProvider" then continue end

		dependencies[value._name] = value
	end
	return dependencies
end

function modding.providerRegistered(listener: types.Callback<types.RegisteredProvider>)
	table.insert(internal.events.providerRegistered, listener)
	return function()
		util.removeFromTable(internal.events.providerRegistered, listener)
	end
end

function modding.singletonRegistered(listener: types.Callback<types.RegisteredProvider>)
	table.insert(internal.events.singletonRegistered, listener)
	return function()
		util.removeFromTable(internal.events.singletonRegistered, listener)
	end
end

return modding

