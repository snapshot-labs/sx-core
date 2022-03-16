interface BigInt3 {
    d0: bigint,
    d1: bigint,
    d2: bigint
}

/**
 * Takes a 256-bit integer and returns its canonical representation as:
 * d0 + BASE * d1 + BASE**2 * d2, where BASE = 2**86.
 * @param address The 256 bit number to split
 * @returns d0, d1 and d2 as bigints
 */
export function u256ToBigInt3(address: string): BigInt3 {
    const BASE = BigInt(Math.pow(2, 86));
    let hex = BigInt(address);

    let rest = hex % BASE;
    hex = hex / BASE;
    const d0 = rest;

    rest = hex % BASE;
    hex = hex / BASE;
    const d1 = rest;

    rest = hex % BASE;
    hex = hex / BASE;
    const d2 = rest;


    if (hex != BigInt(0)) {
        // Error, hex should've been fully divided
        return {d0: BigInt(0), d1: BigInt(0), d2: BigInt(0)};
    }

    return {d0, d1, d2};
  }
