--!strict
local types = require(script.types)
local nit = require(script.nit)
local modding = require(script.modding)
local provider = require(script.provider)

export type Provider<T={}> = types.Provider<T>
export type RegisteredProvider<T={}> = types.RegisteredProvider<T>

return nit.extend(nit, provider, { modding = modding })