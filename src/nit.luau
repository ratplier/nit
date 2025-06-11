local RunService = game:GetService("RunService")

local types = require("./types")
local utils = require("./util")
local modding = require("./modding")

local hasIgnited = false

local loadedProviders = {}
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

local function linkModuleLifecycles(module: { [any]: any })
    for key, value in module do
        if modding.isLifecycleRegistered(key) then continue end
        if typeof(value) ~= "function" then continue end

        modding.registerLifecycleListener(key, value)
    end
end

local nit = {}

function nit.loadDescendants(parent: Instance, predicate: types.Predicate<Instance>?)
	for _, descendant in parent:GetDescendants() do
		if not descendant:IsA("ModuleScript") then continue end
        if loadedProviders[descendant] then continue end

        if not predicate or predicate(descendant) then continue end

        loadedProviders[descendant] = true
	end
end

function nit.loadChildren(parent: Instance, predicate: types.Predicate<Instance>?)
	nit.loadDescendants(parent, function(descendant: Instance)
		local valid = descendant.Parent == parent
		return valid and (not predicate or predicate(descendant))
	end)
end

function nit.matchesName(name: string): types.Predicate<Instance>
	return function(moduleScript) return moduleScript.Name == name end
end

function nit.ignite()
    if hasIgnited then return end
    hasIgnited = true

    local dependencies = {}
    for _, provider in modding.getSingletons() do
        table.insert(dependencies, {
            name = provider._name,
            priority = provider._priority
        })
    end

    local dependencyNames = utils.map(dependencies, function(dependency)
        return dependency.name
    end)

    local sorted = topologicalSort(dependencyNames)
    table.sort(dependencies, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return sorted[a.name] < sorted[b.name]
    end)

    for _, dependency in dependencies do
        local provider = modding.getSingleton(dependency.name)
        local module = require(provider)
        linkModuleLifecycles(module)
    end

    local maid = utils.maid()

	local start = modding.addLifecycle("onStart")
	local stop = modding.addLifecycle("onStop")
	local beat = modding.addLifecycle("onTick")
	local render = modding.addLifecycle("onRender")
	local physics = modding.addLifecycle("onPhysics")
	local init = modding.addLifecycle("onInit")

    init()

    maid.add(RunService.RenderStepped:Connect(render))
    maid.add(RunService.Heartbeat:Connect(beat))
    maid.add(RunService.Stepped:Connect(physics))

    start()

    modding.registerLifecycleListener("onStop", maid.cleanup)
    return stop
end

return nit