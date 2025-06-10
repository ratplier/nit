--!strict
local types = require("./types")

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