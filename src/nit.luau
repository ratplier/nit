--!strict
local RunService = game:GetService("RunService")

local types = require("./types")
local util = require("./util")
local modding = require("./modding")
local constants = require("./constants")

local VERSION = constants.VERSION

local function topologicalSort(objects: { string }): { [string]: number }
    local currentSize = 0
    local sorted: { [string]: number } = {}
    local visited: { [string]: true } = {}

    local function visitor(node: string)
        if visited[node] then return end
        visited[node] = true

        local object = modding.getSingleton(node)
        if not object then return end

        local dependencies = modding.getDependencies(object)
        for _, dependency in dependencies do
            visitor(dependency._name)
        end

        currentSize += 1
        sorted[node] = currentSize
    end

    for _, node in objects do
        visitor(node)
    end

    return sorted
end

local nit = {}

function nit.loadDescendants(parent: Instance, predicate: types.Predicate<Instance>?)
    modding.loadDescendants(parent, predicate)
end

function nit.loadChildren(parent: Instance, predicate: types.Predicate<Instance>?)
    modding.loadChildren(parent, predicate)
end

function nit.matchesName(name: string): types.Predicate<Instance>
	return function(moduleScript) return moduleScript.Name == name end
end

function nit.ignite()
    util.assert( modding.ignited(), constants.errors.alreadyIgnited, "ignite" )

    local dependencies: { { name: string, priority: number} } = {}
    for _, provider in modding.getSingletons() do
        table.insert(dependencies, {
            name = provider._name,
            priority = provider._priority
        })
    end

    local dependencyNames = util.map(dependencies, function(dependency)
        return dependency.name
    end) :: { string }

    local sorted = topologicalSort(dependencyNames)
    table.sort(dependencies, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return sorted[a.name] < sorted[b.name]
    end)

    local maid = util.maid()

    for _, dependency in dependencies do
        local provider = modding.getSingleton(dependency.name)
        modding.loadProviderLifecycles(provider)
    end

	local start = modding.createLifecycle("onStart")
	local stop = modding.createLifecycle("onStop")
	local beat = modding.createLifecycle("onTick")
	local render = modding.createLifecycle("onRender")
	local physics = modding.createLifecycle("onPhysics")
	local init = modding.createLifecycle("onInit")

    init()

    maid.add(RunService.RenderStepped:Connect(render))
    maid.add(RunService.Heartbeat:Connect(beat))
    maid.add(RunService.Stepped:Connect(physics))

    start()

    modding.watchLifecycle("onStop", maid.cleanup)
    return stop
end

nit.extend = function(...: types.DynamicTable)
	local result = {}
    for i = 1, select("#", ...) do
        local source = select(i, ...)
		for key, value in source do
			result[key] = value
		end
	end
	return result
end :: types.Extender

nit.listen = function(name: string, listener: types.Callback)
    modding.watchLifecycle("onInit", nit.ignite)
end

nit.onInit = function(listener) nit.listen("onInit", listener) end
nit.onIgnition = function(listener) nit.listen("onStart", listener) end
nit.onRelease = function(listener) nit.listen("onStop", listener) end

nit.onRender = function(listener) nit.listen("onRender", listener) end
nit.onUpdate = function(listener) nit.listen("onTick", listener) end
nit.onPhysics = function(listener) nit.listen("onPhysics", listener) end

nit.version = `nit {VERSION.major}.{VERSION.minor}.{VERSION.patch}`
return nit:extend()