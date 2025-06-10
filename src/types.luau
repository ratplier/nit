--!strict
export type Callback<A...=...unknown, R...=...unknown> = (A...) -> R...
export type DynamicTable<T={}> = T & { [any]: any }

export type providerType = "provider" | "registeredProvider"

export type Provider<T={}> = {
    _type: "provider" & providerType,
} & DynamicTable<T>

export type RegisteredProvider<T={}> = {
    _type: "registeredProvider" & providerType,
    _priority: number,
    _name: string?,
} & DynamicTable<T>

return {}