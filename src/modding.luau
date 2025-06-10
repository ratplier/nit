local types = require("./types")
local util = require("./util")

local internal = {
    events = {
        lifecycleAdded = {},
        lifecycleExecuted = {},
        lifecycleRegistered = {},
        lifecycleUnregistered = {},

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

function modding.registerLifecycle(name: string, callback: types.Callback<any>)
    if not internal.lifecycles[name] then return end

    table.insert(internal.lifecycles[name], callback)
    fireConcurrent(internal.events.lifecycleRegistered, name, callback)
end

function modding.unregisterLifecycle(name: string, callback: types.Callback<any>)
    if not internal.lifecycles[name] then return end

    util.removeFromTable(internal.lifecycles[name], callback)
    fireConcurrent(internal.events.lifecycleUnregistered, name, callback)
end

function modding.executeLifecycle(name: string, ...: any)
    if not internal.lifecycles[name] then return end
    local lifecycles = internal.lifecycles[name]

    if name == "onInit" then
        fireSequential(lifecycles, ...)
    else
        fireConcurrent(lifecycles, ...)
    end

    fireConcurrent(internal.events.lifecycleExecuted, name, ...)
end

function modding.addLifecycle(name: string)
    if internal.lifecycles[name] then return end

    internal.lifecycles[name] = {}
    fireConcurrent(internal.events.lifecycleAdded, name)
end

function modding.registerProvider(provider: types.RegisteredProvider<any>)
    fireConcurrent(internal.events.providerRegistered, provider)
end

function modding.mountSingleton(name: string, provider: types.Provider<any>)
    if internal.singletons[name] then return end

    internal.singletons[name] = provider
    fireConcurrent(internal.events.singletonMounted, provider)
end

function modding.singletonExists(name: string)
    return internal.singletons[name] ~= nil
end

return modding

