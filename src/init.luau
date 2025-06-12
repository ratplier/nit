--!strict
local types = require(script.types)
<<<<<<< HEAD
local extras = require(script.extras)
local modding = require(script.modding)
local provider = require(script.provider)

export type Provider<T={}> = types.Provider<T>
export type RegisteredProvider<T={}> = types.RegisteredProvider<T>

return extras.extend({
    modding = modding,
}, provider, extras)
=======

export type Predicate<T> = types.Predicate<T>
export type RegisteredProvider<T> = types.RegisteredProvider<T>
export type Provider<T> = types.Provider<T>

local loader = require(script.loader)
local provider = require(script.provider)

local VERSION = {
	major = 1,
	minor = 0,
	patch = 0,
}

local extend = function(...)
	local result = {}
	for _, source in { ... } do
		for key, value in source do
			result[key] = value
		end
	end
	return result
end

local lib = {
	-- provider
	register = provider.register,
	use = provider.use,
	createProvider = provider.createProvider,

	-- loading
	loadDescendants = loader.loadDescendants,
	loadChildren = loader.loadChildren,
	matchesName = loader.matchesName,
	ignite = loader.ignite,
	addLifecycle = loader.addLifecycle,

	-- lifecycles
	onIgnition = loader.onIgnition,
	onRelease = loader.onRelease,
	onTick = loader.onTick,
	onPhysics = loader.onPhysics,
	onRender = loader.onRender,
	onInit = loader.onInit,
	listen = loader.listen,

	version = `nit {VERSION.major}.{VERSION.minor}.{VERSION.patch}`,
}

lib.extend = extend :: types.ExtendFunction<typeof(lib)>

return lib
>>>>>>> origin/master
