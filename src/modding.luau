local types = require("./types")
local util = require("./util")

local events = {
    lifecycleAdded = {},
    lifecycleExecuted = {},
    lifecycleRegistered = {},
    lifecycleUnregistered = {},
}
local modding = {
    lifecycles = {
        onInit = {},
        onStart = {},
        onStop = {},
        onTick = {},
        onPhysics = {},
        onRender = {},
    },
}

local function fireConcurrent<A...>(listeners: { types.Callback<A...> }, ...: A...)
    util.spawnCallbacks(listeners, ...)
end

local function fireSequential<A...>(listeners: { types.Callback<A...> }, ...: A...)
    for _, listener in listeners do
        listener(...)
    end
end

function modding.registerLifecycle(name: string, callback: types.Callback<any>)
    if not modding.lifecycles[name] then return end

    table.insert(modding.lifecycles[name], callback)
    fireConcurrent(events.lifecycleRegistered, name, callback)
end

function modding.unregisterLifecycle(name: string, callback: types.Callback<any>)
    if not modding.lifecycles[name] then return end

    util.removeFromTable(modding.lifecycles[name], callback)
    fireConcurrent(events.lifecycleUnregistered, name, callback)
end

function modding.executeLifecycle(name: string, ...: any)
    if not modding.lifecycles[name] then return end
    local lifecycles = modding.lifecycles[name]

    if name == "onInit" then
        fireSequential(lifecycles, ...)
    else
        fireConcurrent(lifecycles, ...)
    end

    fireConcurrent(events.lifecycleExecuted, name, ...)
end

function modding.addLifecycle(name: string)
    if modding.lifecycles[name] then return end

    modding.lifecycles[name] = {}
    fireConcurrent(events.lifecycleAdded, name)
end

return modding

