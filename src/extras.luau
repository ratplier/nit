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

local extras = {}

function extras.createLifecycle(name: string)
    return modding.createLifecycle(name)
end

function extras.loadDescendants(parent: Instance, predicate: types.Predicate<Instance>?)
    modding.loadDescendants(parent, predicate)
end

function extras.loadChildren(parent: Instance, predicate: types.Predicate<Instance>?)
    modding.loadChildren(parent, predicate)
end

function extras.matchesName(name: string): types.Predicate<Instance>
	return function(moduleScript) return moduleScript.Name == name end
end

function extras.ignite()
	util.assert( not modding.ignited(), constants.errors.alreadyIgnited, "ignite" )

	local dependencies: { { name: string, priority: number } } = {}
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
			return a.priority > b.priority
		end

		return sorted[a.name] > sorted[b.name]
	end)

	local maid = util.maid()

	local start = modding.createLifecycle("onStart")
	local stop = modding.createLifecycle("onStop")
	local beat = modding.createLifecycle("onTick")
	local render = modding.createLifecycle("onRender")
	local physics = modding.createLifecycle("onPhysics")
	local init = modding.createLifecycle("onInit")

	modding.watchLifecycle("onStop", maid.cleanup)
	init()
	modding.ignite()
	
	for _, dependency in dependencies do
		local provider = modding.getSingleton(dependency.name)
		modding.loadProviderLifecycles(provider)
	end

	if RunService:IsClient() then
		maid.add(RunService.RenderStepped:Connect(render))
	end
	maid.add(RunService.Heartbeat:Connect(beat))
	maid.add(RunService.Stepped:Connect(physics))

	start()

	return stop
end

extras.extend = function(...: types.DynamicTable)
	local result = {}
    for i = 1, select("#", ...) do
        local source = select(i, ...)
		for key, value in source do
			result[key] = value
		end
	end
	return result
end :: types.Extender

extras.listen = function(name: string, listener: types.Callback)
    modding.watchLifecycle(name, listener)
end

extras.onInit = function(listener) extras.listen("onInit", listener) end
extras.onIgnition = function(listener) extras.listen("onStart", listener) end
extras.onRelease = function(listener) extras.listen("onStop", listener) end

extras.onRender = function(listener) extras.listen("onRender", listener) end
extras.onUpdate = function(listener) extras.listen("onTick", listener) end
extras.onPhysics = function(listener) extras.listen("onPhysics", listener) end

extras.onTick = function(...)
    warn("extras.onTick is deprecated, use extras.onUpdate instead")
    return extras.onUpdate(...)
end
extras.addLifecycle = function(...)
    warn("extras.addLifecycle is deprecated, use extras.createLifecycle instead")
    return extras.createLifecycle(...)
end

extras.version = `nit {VERSION.major}.{VERSION.minor}.{VERSION.patch}`
return extras:extend()