# nit
inspired by **ohmyprvd** *(v0.1)* and **flamework**

```lua
local nit = require(path.to.nit)
```

### core features

| Function                                 | Description                                                                         |
| ---------------------------------------- | ------------------------------------------------------------------------------------|
| `nit.register(provider, name)`           | registers a provider with an optional name                                          |
| `nit.use(provider, priority)`            | marks a provider as used and assigns it a priority                                  |
| `nit.createProvider(provider)`           | creates a empty provider                                                            |
| `nit.loadDescendants(parent, predicate)` | loads all descendant providers of a parent with a optional predicate                |
| `nit.loadChildren(parent, predicate)`    | loads all children providers of a parent with optional predicate                    |
| `nit.matchesName(name)`                  | built-in predicate function that matches providers by name                          |
| `nit.ignite()`                           | starts the framework, initializing and running registered providers                 |
| `nit.extend(table1, table2, ...)`        | merges multiple tables into a new table. used for extending the base nit interface  |

---

## lifecycles
onInit - runs lifecycles sequentially before ignition
onStart - runs lifecycles at once post ignition
onTick - equivalent to `RunService.Heartbeat`
onPhysics - equivalent to `RunService.Stepped`
onRender - client only, equivalent to `RunService.RenderStepped`

## examples

boilerplate
```lua
-- boilerplate.luau
local nit = require("nit")
local provider = nit.createProvider({})

return nit.register(provider, "myProviderName") -- Name is optional.
-- registering with a name makes it a singleton
```

---

custom lifecycle
```lua
-- CameraProvider.luau
local nit = require("nit")
local provider = nit.createProvider({
	camera = workspace.CurrentCamera
})

function provider.onStart(self: CameraProvider)
	self.camera = workspace.CurrentCamera
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		self.camera = workspace.CurrentCamera
	end)
end

function provider.renderStep(self: CameraProvider, dt: number)
	self.camera.CFrame *= CFrame.new(0, 5*dt, 0)
end

export type CameraProvider = typeof(provider)
return nit.register(provider)
```
```lua
-- main.client.luau
local RunService = game:GetService("RunService")
local nit = require("nit")

local render = nit.addLifecycle("renderStep")
RunService.RenderStepped:Connect(render)

nit.loadDescendants(path.to.providers)
nit.ignite()
```

---

## plugins
plugins extend the core framework. they should be loaded before `nit.ignite()`. initalize plugins using the `nit:extend()` method

### create a plugin
```lua
-- Instance.luau
return {
	create = Instance.new,
	fromExisting = Instance.fromExisting
}
```
```lua
-- main.client.luau
local nit = require("nit")
local instance = require(path.to.Instance)

nit = nit:extend(instance) -- extend nit with the plugin
print(nit.create("Part").ClassName == "Part") -- true
```

---

```lua
local nit = require("nit")
local pluginsA = require("pluginsA")
local pluginsB = require("pluginsB")

-- extend nit with both plugins at once for proper typechecking
nit = nit:extend(pluginsA, pluginsB)
nit = nit:extend(pluginsA):extend(pluginsB) -- avoid this! Only pluginsB will be typechecked with nit.
```
