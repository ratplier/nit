--!strict
export type Callback<A...=...unknown, R...=...unknown> = (A...) -> R...
export type Predicate<T> = (T) -> boolean
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

export type ExtendFunction<T={}> =
    & ((self: T) -> External<T>)
	& (<A>(self: T, A: A) -> A & T & External<T>)
	& (<A, B>(self: T, A: A, B: B) -> A & B & T & External<T>)
	& (<A, B, C>(self: T, A: A, B: B, C: C) -> A & B & C & T & External<T>)
	& (<A, B, C, D>(self: T, A: A, B: B, C: C, D: D) -> A & B & C & D & T & External<T>)
	& (<A, B, C, D, E>(self: T, A: A, B: B, C: C, D: D, E: E) -> A & B & C & D & E & T & External<T>)
	& (<A, B, C, D, E, F>(self: T, A: A, B: B, C: C, D: D, E: E, F: F) -> A & B & C & D & E & F & T & External<T>)
	& (<A, B, C, D, E, F, G>(self: T, A: A, B: B, C: C, D: D, E: E, F: F, G: G) -> A & B & C & D & E & F & G & T & External<T>)
	& (<A, B, C, D, E, F, G, H>(self: T, A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H) -> A & B & C & D & E & F & G & H & T & External<T>)
	& (<A, B, C, D, E, F, G, H, I>(self: T, A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H, I: I) -> A & B & C & D & E & F & G & H & I & T & External<T>)
	& (<A, B, C, D, E, F, G, H, I, J>(self: T, A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H, I: I, J: J) -> A & B & C & D & E & F & G & H & I & J & T & External<T>)
	& (<A, B, C, D, E, F, G, H, I, J, K>(self: T, A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H, I: I, J: J, K: K) -> A & B & C & D & E & F & G & H & I & J & K & T & External<T>)

export type External<T> = {
	extend: ExtendFunction<T>
} & T

return {}