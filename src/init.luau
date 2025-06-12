--!strict
local types = require(script.types)
local extras = require(script.extras)
local modding = require(script.modding)
local provider = require(script.provider)

export type Provider<T={}> = types.Provider<T>
export type RegisteredProvider<T={}> = types.RegisteredProvider<T>

return extras.extend({
    modding = modding,
}, provider, extras)
