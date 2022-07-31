//@ts-ignore
export const uniq = <T>(a: T[]) => [...new Set(a)]

export const removeDuplicatesBy =
  <T, K extends keyof T>(key: K) =>
  (array: T[]) =>
    array.filter((v, i, a) => a.findIndex((x) => x[key] === v[key]) === i)
