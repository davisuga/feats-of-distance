export const tap =
  <T>(eff: (p: T) => void) =>
  (x: T) => {
    eff(x)
    return x
  }
