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
	& (<A, B>(A: A, B: B) -> A & B & External<T>)
	& (<A, B, C>(A: A, B: B, C: C) -> A & B & C & External<T>)
    & (<A, B, C, D>(A: A, B: B, C: C, D: D) -> A & B & C & D & External<T>)
    & (<A, B, C, D, E>(A: A, B: B, C: C, D: D, E: E) -> A & B & C & D & E & External<T>)
    & (<A, B, C, D, E, F>(A: A, B: B, C: C, D: D, E: E, F: F) -> A & B & C & D & E & F & External<T>)
    & (<A, B, C, D, E, F, G>(A: A, B: B, C: C, D: D, E: E, F: F, G: G) -> A & B & C & D & E & F & G & External<T>)
    & (<A, B, C, D, E, F, G, H>(A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H) -> A & B & C & D & E & F & G & H & External<T>)
    & (<A, B, C, D, E, F, G, H, I>(A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H, I: I) -> A & B & C & D & E & F & G & H & I & External<T>)
    & (<A, B, C, D, E, F, G, H, I, J>(A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H, I: I, J: J) -> A & B & C & D & E & F & G & H & I & J & External<T>)
    & (<A, B, C, D, E, F, G, H, I, J, K>(A: A, B: B, C: C, D: D, E: E, F: F, G: G, H: H, I: I, J: J, K: K) -> A & B & C & D & E & F & G & H & I & J & K & External<T>)

export type External<T> = T & {
	extend: ExtendFunction<T>
}

return {}