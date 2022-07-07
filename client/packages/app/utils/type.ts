export type ItemOf<A> = A extends Array<infer I> ? I : never
