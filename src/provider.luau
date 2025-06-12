--!strict
local types = require("./types")
<<<<<<< HEAD
local util = require("./util")
local modding = require("./modding")
local constants = require("./constants")
local provider = {}

function provider.createProvider<T>(provider: types.DynamicTable<T>): T
    return modding.createProvider(provider)
end

function provider.register<T>(provider: types.Provider<T>, name: string?): T
    util.assert( provider._type == "provider", constants.errors.invalidProviderType, "provider", provider._type, provider._name )
    util.assert( not modding.isProviderRegistered(provider), constants.errors.providerAlreadyRegistered, provider._name )
    util.assert( name == nil or not modding.isSingletonRegistered(name), constants.errors.singletonAlreadyRegistered, name )

    local registeredProvider: types.RegisteredProvider<T> = provider
    registeredProvider._name = name
    registeredProvider._priority = registeredProvider._priority or 1
    registeredProvider._type = "registeredProvider"

    if name ~= nil then
        modding.registerSingleton(name, registeredProvider)
    else
        modding.registerProvider(registeredProvider)
    end
    return registeredProvider
end

function provider.use<T>(provider: types.RegisteredProvider<T>): T
	util.assert( provider._type == "registeredProvider", constants.errors.invalidProviderType, "provider", provider._type, provider._name )
    return provider
end

return provider
=======

local providers = {}

local function use<T>(provider: T, priority: number?): T
	local _provider = provider :: types.RegisteredProvider<T>
	assert(_provider._type == "registeredProvider", "Cannot use an unregistered provider")
	
	local _priority = if type(priority) == "number" then priority else 1
	_provider.priority += _priority
	return _provider
end

local function register<T>(provider: T, name: string?): T
	local _provider = provider :: types.Provider<T>
	assert(_provider._type == "provider", "Only providers can be registered. Did you pass a registered provider?")
	assert(name == nil or providers[name] == nil, "Provider with this name already registered") 

	if name then
		providers[name] = _provider
	end
	
	_provider.priority = _provider.priority or 1
	_provider.name = name
	_provider._type = "registeredProvider"
	
	return _provider :: types.RegisteredProvider<T>
end

local function createProvider<T>(provider: T & {}): T
	local _provider = (provider or {})::any
	_provider._type = "provider"
	return _provider
end

return {
	use = use,
	register = register,
	createProvider = createProvider,
}
>>>>>>> origin/master
