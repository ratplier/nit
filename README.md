# nit
inspired by **ohmyprvd** *(v0.1)* and **flamework**  
goal is to be flamework but for luau  
so far partially there

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
| `nit.ignite()`                           | starts the framework, initializing and running registered providers                 |

### extras

| Function                                 | Description                                                                         |
| ---------------------------------------- | ------------------------------------------------------------------------------------|
| `nit.extend(table1, table2, ...)`        | merges multiple tables into a new table. used for extending the base nit interface  |
| `nit.matchesName(name)`                  | built-in predicate function that matches providers by name                          |
| `nit.onInit(listener)`                   | listens to `onInit` lifecycle                                                       |
| `nit.onTick(listener)`                   | listens to `onTick` lifecycle                                                     	 |
| `nit.onPhysics(listener)`                | listens to `onPhysics` lifecycle                                                    |
| `nit.onRender(listener)`                 | listens to `onRender` lifecycle on the client                                       |
| `nit.onRelease(listener)`                | listens to `onRelease` lifecycle                                                    |
| `nit.createLifecycle(name)`              | creates a custom lifecycle with the given name                                      |

### modding

| Function                                    | Description                            |
| --------------------------------------------| ---------------------------------------|
| `modding.providerRegistered(listener)`      | listens to provider registrations      |
| `modding.singletonRegistered(listener)`     | listens to singleton registrations     |
| `modding.lifecycleRegistered(name)`         | listens to lifecycle registrations     |
| `modding.providerUnregistered(provider)`    | listens to provider unregistrations    |
| `modding.singletonUnregistered(name)`       | listens to singleton unregistrations   |
| `modding.getSingleton(name)`                | returns a registered singleton by name |
| `modding.getProviders()`                    | returns all registered providers       |
| `modding.getSingleton(name)`                | returns a registered singleton by name |


---

## built-in lifecycles
| Lifecycle   | Description                                         |
|-------------|-----------------------------------------------------|
| **onInit**  | Runs lifecycles sequentially before ignition        |
| **onStart** | Runs lifecycles at once post ignition               |
| **onTick**  | Equivalent to `RunService.Heartbeat`                |
| **onPhysics** | Equivalent to `RunService.Stepped`                |
| **onRender** | Client only, equivalent to `RunService.RenderStepped` |

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
nit.loadDescendants(path.to.providers)
nit.ignite()

-- make sure to activate lifecycles after ignition
RunService.RenderStepped:Connect(render)
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
-- 

print(nit.create("Part").ClassName == "Part") -- true
```
> [!CAUTION]
> make sure to use nit:extend instead of nit.extend or else you will have to manually pass nit into the extend call `nit.extend(nit, ...)`  
