local types = require("./types")
local utils = {}

local _freeThreads: { thread } = {}
local function _resume(resume, thread, ...)
    resume(...)
    table.insert(_freeThreads, thread)
end

local function _yield()
    while true do
        _resume(coroutine.yield())
    end
end

function utils.spawnCallback<A...>(callback: types.Callback<A...>, ...: A...)
    local thread: thread = table.remove(_freeThreads) :: thread
    if thread == nil then
        thread = coroutine.create(_yield)
        coroutine.resume(thread)
    end
    task.spawn(thread, callback, thread, ...)
end

function utils.spawnCallbacks<A...>(callbacks: { types.Callback<A...> }, ...: A...)
    for _, callback in callbacks do
        utils.spawnCallback(callback)
    end
end

function utils.removeFromTable<T>(tbl: { T }, value: T)
    local index = table.find(table, value)
    if not index then return end
    table.remove(tbl, index)
end

return table.freeze(utils)
