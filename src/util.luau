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

function utils.map<T>(tbl: { T }, callback: types.Callback<T>)
    local result = {}
    for _, value in tbl do
        table.insert(result, callback(value))
    end
    return result
end

function utils.maid()
    local bin = {}
    type trash = types.Callback | RBXScriptConnection

    local function add(trash: trash)
        table.insert(bin, trash)
    end

    local function remove(trash: trash)
        utils.removeFromTable(bin, trash)
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

return table.freeze(utils)
