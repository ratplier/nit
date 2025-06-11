--!strict
local types = require("./types")
local util = {}

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

function util.spawnCallback<A...>(callback: types.Callback<A...>, ...: A...)
    local thread: thread = table.remove(_freeThreads) :: thread
    if thread == nil then
        thread = coroutine.create(_yield)
        coroutine.resume(thread)
    end
    task.spawn(thread, callback, thread, ...)
end

function util.spawnCallbacks<A...>(callbacks: { types.Callback<A...> }, ...: A...)
    for _, callback in callbacks do
        util.spawnCallback(callback)
    end
end

function util.removeFromTable<T>(tbl: { T }, value: T)
    local index = table.find(table, value)
    if not index then return end
    table.remove(tbl, index)
end

function util.map<T, R>(tbl: { T }, callback: types.Callback<(T), (R)>): { R }
    local result = {}
    for _, value in tbl do
        table.insert(result, callback(value))
    end
    return result
end

function util.maid()
    local bin = {}
    type trash = types.Callback | RBXScriptConnection

    local function add(trash: trash)
        table.insert(bin, trash)
    end

    local function remove(trash: trash)
        util.removeFromTable(bin, trash)
    end

    local function cleanup()
        for _, trash in bin do
            if typeof(trash) == "RBXScriptConnection" then
                trash:Disconnect()
            else
                trash()
            end
        end

        table.clear(bin)
    end

    return {
        add = add,
        remove = remove,
        cleanup = cleanup,
    }
end

function util.saferequire(path: Instance): any?
    local success, result = pcall(require, path)
    return success and result
end

function util.contains(tbl: { any }, value: any)
    return table.find(tbl, value) ~= nil
end

function util.assert(condition: boolean, ...: any)
    if condition == nil or condition == false then
        error(string.format(...), 3)
    end
end

return table.freeze(util)
