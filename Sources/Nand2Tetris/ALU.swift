func alu(
    x: String,
    y: String,
    zx: Char,
    nx: Char,
    zy: Char,
    ny: Char,
    f: Char,
    no: Char
) -> (out: String, zr: Char, ng: Char) {
    let xZX = zeroIfZ(x, z: zx)
    let yZY = zeroIfZ(y, z: zy)
    
    let xNXZX = negateIfN(xZX, n: nx)
    let yNYZY = negateIfN(yZY, n: ny)
    
    let andOut = and16(xNXZX, yNYZY)
    let addOut = add16(xNXZX, yNYZY)

    let f_out = mux16(andOut, addOut, f)
    let not_f_out = not16(f_out)
    let noModified_fOut = mux16(f_out, not_f_out, no)
    
    let ng = isNegative(noModified_fOut)
    let zr = isZero(noModified_fOut)
    
    return (noModified_fOut, zr, ng)
}

private func negateIfN(_ a: String, n: Char) -> String {
    mux16(a, not16(a), n)
}

private func zeroIfZ(_ a: String, z: Char) -> String {
    mux16(a, zero(a), z)
}
