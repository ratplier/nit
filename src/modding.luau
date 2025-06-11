--!strict
local types = require("./types")
local util = require("./util")
local constants = require("./constants")

local internal = {
	events = {
        lifecycleRegistered = {} :: { types.Callback<string> },
        lifecycleWatched = {} :: { types.Callback<string> },
        lifecycleUnwatched = {} :: { types.Callback<string> },

		singletonRegistered = {} :: { types.Callback<types.RegisteredProvider> },
		providerRegistered = {} :: { types.Callback<types.RegisteredProvider> },
	},

    loadedProviders = {},
    lifecycles = {},
    providers = {},
	singletons = {},

	errors = constants.errors,
    ignited = false,
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
    local lifecycle = internal.lifecycles[name]
    if not lifecycle then return end

    if name == "onInit" then
        fireConcurrent(lifecycle, ...)
    else
        fireSequential(lifecycle, ...)
    end
end

function modding.registerLifecycle(name: string)
    internal.lifecycles[name] = internal.lifecycles[name] or {}
end

function modding.createLifecycle(name: string)
    modding.registerLifecycle(name)
    return function(...)
        executeLifecycle(name, ...)
    end
end

function modding.watchLifecycle(name: string, callback: types.Callback<any>)
    modding.registerLifecycle(name)
    table.insert(internal.lifecycles[name], callback)

    return function()
        modding.unwatchLifecycle(name, callback)
    end
end

function modding.unwatchLifecycle(name: string, callback: types.Callback<any>)
    local lifecycle = internal.lifecycles[name]
    if not lifecycle then return end
    util.removeFromTable(lifecycle, callback)
end

function modding.loadProvider(provider: types.RegisteredProvider)
    internal.loadedProviders[provider] = true
end

function modding.loadDescendants(parent: Instance, predicate: types.Predicate<Instance>?)
	for _, descendant in parent:GetDescendants() do
        if predicate and not predicate(descendant) then continue end
		if not descendant:IsA("ModuleScript") then continue end

        local provider = util.saferequire(descendant)
        if not modding.isProvider(provider) then continue end
        modding.loadProvider(provider :: types.RegisteredProvider)
	end
end

function modding.loadChildren(parent: Instance, predicate: types.Predicate<Instance>?)
	modding.loadDescendants(parent, function(descendant: Instance)
		local valid = descendant.Parent == parent
		return valid and (not predicate or predicate(descendant))
	end)
end

function modding.matchesName(name: string): types.Predicate<Instance>
	return function(moduleScript) return moduleScript.Name == name end
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

function modding.getProvider(name: string)
    return internal.providers[name]
end

function modding.getProviders()
    return internal.providers
end

function modding.isProviderRegistered(name: string)
    return internal.providers[name] ~= nil
end

function modding.isProvider(provider: any)
    return typeof(provider) == "table" and provider._type == "registeredProvider"
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

