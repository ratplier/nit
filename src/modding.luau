--!strict
local types = require("./types")
local util = require("./util")

local internal = {
    events = {
        lifecycleAdded = {},
        lifecycleExecuted = {},
        lifecycleListenerRegistered = {},
        lifecycleListenerUnregistered = {},

        providerRegistered = {},
        singletonMounted = {},
    },
    lifecycles = {},
    singletons = {},
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
    if not internal.lifecycles[name] then return end
    local lifecycles = internal.lifecycles[name]

    if name == "onInit" then
        fireSequential(lifecycles, ...)
    else
        fireConcurrent(lifecycles, ...)
    end

    fireConcurrent(internal.events.lifecycleExecuted, name, ...)
end

function modding.registerLifecycleListener(name: string, callback: types.Callback<any>)
    if not internal.lifecycles[name] then
        modding.addLifecycle(name)
    end

    table.insert(internal.lifecycles[name], callback)
    fireConcurrent(internal.events.lifecycleListenerRegistered, name, callback)
end

function modding.unregisterLifecycleListener(name: string, callback: types.Callback<any>)
    if not internal.lifecycles[name] then return end

    util.removeFromTable(internal.lifecycles[name], callback)
    fireConcurrent(internal.events.lifecycleListenerUnregistered, name, callback)
end

function modding.addLifecycle(name: string): types.Callback<...any>
    internal.lifecycles[name] = {}
    fireConcurrent(internal.events.lifecycleAdded, name)

    return function(...)
        executeLifecycle(name, ...)
    end
end

function modding.isLifecycleRegistered(name: string)
    return internal.lifecycles[name] ~= nil
end

function modding.mountSingleton(name: string, provider: types.Provider)
    if internal.singletons[name] then return end

    internal.singletons[name] = provider
    fireConcurrent(internal.events.singletonMounted, provider)
end

function modding.getSingleton(name: string)
    return internal.singletons[name]
end

function modding.getSingletons()
    return internal.singletons
end

function modding.singletonExists(name: string)
    return internal.singletons[name] ~= nil
end

function modding.registerProvider(provider: types.RegisteredProvider)
    fireConcurrent(internal.events.providerRegistered, provider)
end

function modding.getDependencies(provider: types.RegisteredProvider)
    local dependencies = {}
    for key, value in provider::any do
        if typeof(value) ~= "table" then continue end
        if value._name == nil then continue end
        if value._type ~= "registeredProvider" then continue end
        
        dependencies[value._name] = value
    end
    return dependencies
end

return modding

