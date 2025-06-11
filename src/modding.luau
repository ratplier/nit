--!strict
local types = require("./types")
local util = require("./util")
local constants = require("./constants")

local internal = {
	events = {
		lifecycleRegistered = {} :: { types.Callback<string> },
		lifecycleListenerRegistered = {} :: { types.Callback<string, types.Callback<any>> },
		lifecycleListenerUnregistered = {} :: { types.Callback<string, types.Callback<any>> },
		
		singletonRegistered = {} :: { types.Callback<types.RegisteredProvider> },
		providerRegistered = {} :: { types.Callback<types.RegisteredProvider> },
	},
	lifecycles = {},
	singletons = {},
	errors = constants.errors,
}

local modding = {}

local function fireConcurrent<A...>(listeners: { types.Callback<A...> }, ...: A...)
	util.spawnCallbacks(listeners, ...)
end

local function fireSequential<A...>(listeners: { types.Callback<A...> }, ...: A...)
	for _, listener in listeners do
		listener(...)
	end
end

local function executeLifecycle(name: string, ...: any)
	if not modding.lifecycleExists(name) then return end
	local lifecycles = internal.lifecycles[name]
	
	if name == "onInit" then
		fireSequential(lifecycles, ...)
	else
		fireConcurrent(lifecycles, ...)
	end
end

function modding.watchLifecycle(name: string, listener: types.Callback<any>)
	if not modding.lifecycleExists(name) then
		modding.createLifecycle(name)
	end

	table.insert(internal.lifecycles[name], listener)
	fireConcurrent(internal.events.lifecycleListenerRegistered, name, listener)
	
	return function()
		modding.unwatchLifecycle(name, listener)
	end
end

function modding.unwatchLifecycle(name: string, listener: types.Callback<any>)
	if not internal.lifecycles[name] then return end

	util.removeFromTable(internal.lifecycles[name], listener)
	fireConcurrent(internal.events.lifecycleListenerUnregistered, name, listener)
end

function modding.isListenerWatching(name: string, callback: types.Callback<any>)
	return modding.lifecycleExists(name) and util.contains(internal.lifecycles[name], callback)
end

function modding.createLifecycle(name: string): types.Callback<...any>
	util.assert( internal.lifecycles[name] == nil, internal.errors.lifecycleRegistered, name )

	internal.lifecycles[name] = {}
	fireConcurrent(internal.events.lifecycleRegistered, name)

	return function(...)
		executeLifecycle(name, ...)
	end
end

function modding.lifecycleExists(name: string)
	return internal.lifecycles[name] ~= nil
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

	fireConcurrent(internal.events.providerRegistered, provider)
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

function modding.lifecycleRegistered(listener: types.Callback<string>)
	table.insert(internal.events.lifecycleRegistered, listener)
	return function()
		util.removeFromTable(internal.events.lifecycleRegistered, listener)
	end
end

function modding.lifecycleListenerRegistered(listener: types.Callback<string>)
	table.insert(internal.events.lifecycleListenerRegistered, listener)
	return function()
		util.removeFromTable(internal.events.lifecycleListenerRegistered, listener)
	end
end

function modding.lifecycleListenerUnregistered(listener: types.Callback<string>)
	table.insert(internal.events.lifecycleListenerUnregistered, listener)
	return function()
		util.removeFromTable(internal.events.lifecycleListenerUnregistered, listener)
	end
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

