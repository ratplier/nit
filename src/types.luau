--!strict
export type Callback<A...=(), R...=()> = (A...) -> R...
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

export type Extender =
    & (<A>(A) -> A)
    & (<A, B>(A, B) -> A & B)
    & (<A, B, C>(A, B, C) -> A & B & C)
    & (<A, B, C, D>(A, B, C, D) -> A & B & C & D)
    & (<A, B, C, D, E>(A, B, C, D, E) -> A & B & C & D & E)
    & (<A, B, C, D, E, F>(A, B, C, D, E, F) -> A & B & C & D & E & F)
    & (<A, B, C, D, E, F, G>(A, B, C, D, E, F, G) -> A & B & C & D & E & F & G)
    & (<A, B, C, D, E, F, G, H>(A, B, C, D, E, F, G, H) -> A & B & C & D & E & F & G & H)
    & (<A, B, C, D, E, F, G, H, I>(A, B, C, D, E, F, G, H, I) -> A & B & C & D & E & F & G & H & I)
    & (<A, B, C, D, E, F, G, H, I, J>(A, B, C, D, E, F, G, H, I, J) -> A & B & C & D & E & F & G & H & I & J)
    & (<A, B, C, D, E, F, G, H, I, J, K>(A, B, C, D, E, F, G, H, I, J, K) -> A & B & C & D & E & F & G & H & I & J & K)
    & (<A, B, C, D, E, F, G, H, I, J, K, L>(A, B, C, D, E, F, G, H, I, J, K, L) -> A & B & C & D & E & F & G & H & I & J & K & L)

return {}