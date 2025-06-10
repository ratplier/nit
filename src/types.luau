--!strict
export type Callback = (...any) -> ...any
export type Predicate<T...> = (T...) -> boolean
export type Lifecycle = (...any) -> ()
export type LifecycleLinker = (callback: Lifecycle) -> ()
export type Listener = (...any) -> ()

export type Provider<T> = {
	name: string?,
	priority: number?,
	_type: "provider" | string,
} & T

export type RegisteredProvider<T> = {
	name: string?,
	priority: number,
	_type: "registeredProvider" | string,
} & Provider<T>

export type LoadedModule<T> = {
	instance: ModuleScript,
	module: Provider<T>,
	priority: number,
}

export type Loader = {
	addLifecycle: (name: string, yield: boolean?) -> Lifecycle,
	loadDescendants: (parent: Instance, predicate: Predicate<Instance>?) -> (),
	loadChildren: (parent: Instance, predicate: Predicate<Instance>?) -> (),
	matchesName: (name: string) -> Predicate<Instance>,
	ignite: () -> (),
	
	onIgnition: LifecycleLinker,
	onRelease: LifecycleLinker,
	onTick: LifecycleLinker,
	onPhysics: LifecycleLinker,
	onInit: LifecycleLinker,
	onRender: LifecycleLinker?,
	
	listen: (name: string, callback: Lifecycle) -> (),
}

export type ExtendFunction<T> = (() -> External<T>)
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