--!strict
local types = require("./types")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ignited = false
local loader = {} :: types.Loader

local loadedModules: { types.LoadedModule<any> } = {}
local lifecycles: { [string]: { types.Callback } } = {
	onInit = {},
	onStart = {},
	onStop = {},
	onTick = {},
	onPhysics = {},
	onRender = {},
}

local MAXIMUM_PRIORITY = 100_000

local function _createLifecycleExecutor(name: string, yield: boolean?)
	return function(...)
		local callbacks = lifecycles[name]
		if not callbacks then return end

		if yield == true then
			for _, callback in callbacks do
				callback(...)
			end
		else
			for _, callback in callbacks do
				task.spawn(callback, ...)
			end
		end
	end
end

local function _addListenerToLifecycle(name: string, callback: types.Callback)
	lifecycles[name] = lifecycles[name] or {}
	table.insert(lifecycles[name], 1, callback)
end

local function _mountModuleLifecycles(names)
	for _, component in loadedModules do
		local module: { [string]: any } = component.module

		for name, callback in module do
			if table.find(names, name) == nil then continue end
			if type(callback) ~= "function" then continue end
			if not lifecycles[name] then continue end
			
			_addListenerToLifecycle(name, function(...)
				if not module[name] then return end
				module[name](module, ...)
			end)
		end
	end
end

local function _addLifecycle(name, yield)
	lifecycles[name] = lifecycles[name] or {}
	_mountModuleLifecycles({name})
	return _createLifecycleExecutor(name, yield)
end

local function loadModule(moduleScript: ModuleScript, predicate: types.Predicate<Instance>?)
	if predicate and not predicate(moduleScript) then return end
	local module = require(moduleScript) :: types.RegisteredProvider<{}>
	
	if typeof(module) ~= "table" then return end
	if module._type ~= "registeredProvider" then return end
	
	table.insert(loadedModules, {
		instance = moduleScript,
		module = module,
		priority = math.min(module.priority or 0, MAXIMUM_PRIORITY),
	})
end

function loader.addLifecycle(name: string, yield: boolean?): types.Lifecycle
	assert(not ignited, "Cannot add lifecycle after igniting")
	assert(lifecycles[name] == nil, "Cannot reuse a lifecycle name")
	
	return _addLifecycle(name)
end

function loader.loadDescendants(parent: Instance, predicate: types.Predicate<Instance>?)
	assert(not ignited, "Cannot load providers after igniting")
	for _, descendant in parent:GetDescendants() do
		if not descendant:IsA("ModuleScript") then continue end
		loadModule(descendant, predicate)
	end
	
	table.sort(loadedModules, function(a, b)
		return a.priority > b.priority
	end)
end

function loader.loadChildren(parent: Instance, predicate: types.Predicate<Instance>?)
	assert(not ignited, "Cannot load providers after igniting")
	loader.loadDescendants(parent, function(descendant: Instance)
		local valid = descendant.Parent == parent
		return valid and (not predicate or predicate(descendant))
	end)
end

function loader.matchesName(name: string): types.Predicate<Instance>
	return function(moduleScript) return moduleScript.Name == name end
end

function loader.ignite()
	assert(not ignited, "Cannot ignite more than once.")
	
	local start = _addLifecycle("onStart")
	local stop = _addLifecycle("onStop")
	local beat = _addLifecycle("onTick")
	local render = _addLifecycle("onRender")
	local physics = _addLifecycle("onPhysics")
	local init = _addLifecycle("onInit", true)
	
	init()
	ignited = true
	start()

	RunService.Heartbeat:Connect(beat)
	RunService.Stepped:Connect(physics)
	
	if RunService:IsClient() then
		RunService.RenderStepped:Connect(render)
		Players.PlayerRemoving:Connect(function(plr)
			if plr ~= Players.LocalPlayer then return end
			stop()
		end)
	else
		game:BindToClose(stop)
	end
end

loader.listen = function(n, f) _addListenerToLifecycle(n, f) end
loader.onInit = function(f) _addListenerToLifecycle("onInit", f) end
loader.onTick = function(f) _addListenerToLifecycle("onTick", f) end
loader.onRelease = function(f) _addListenerToLifecycle("onStop", f) end
loader.onRender = function(f) _addListenerToLifecycle("onRender", f) end
loader.onIgnition = function(f) _addListenerToLifecycle("onStart", f) end
loader.onPhysics = function(f) _addListenerToLifecycle("onPhysics", f) end

return loader :: types.Loader