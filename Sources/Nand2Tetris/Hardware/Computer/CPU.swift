class CPU {
    struct Out: Equatable {
        let mValue: String
        let shouldWrite: Char
        let aValue: String
        let pcValue: String
    }
    
    let aRegister: Register16
    let dRegister: Register16
    let pcRegister: PC
    
    init(
        aRegister: Register16 = Register(),
        dRegister: Register16 = Register(),
        pcRegister: PC = PC(register: Register())
    ) {
        self.aRegister = aRegister
        self.dRegister = dRegister
        self.pcRegister = pcRegister
    }
    
    @discardableResult
    func callAsFunction(
        _ mValue: String,
        _ code: String,
        _ shouldReset: Char,
        _ clock: Char
    ) -> Out {
        let isComputation = code[0]
        let zero = xor(isComputation, isComputation)
        
        func setA() -> Out {
            let a = aRegister(code, not(isComputation), clock)
            let pc = pcRegister(a,
                                zero,
                                zero,
                                not(isComputation),
                                clock)
            
            return Out(mValue: a,
                       shouldWrite: isComputation,
                       aValue: a,
                       pcValue: pc)
        }
        
        func computeCode() -> Out {
            func shouldAct(_ bit: Char) -> Char {
                and(bit, isComputation)
            }
            
            let isMCode = code[3]
            let aluCode = String(code.dropFirst(4).prefix(6))
            let destination = String(code.dropFirst(10).prefix(3))
            let jump = String(code.dropFirst(13))
            
            let initialA = aRegister(code, zero, clock)
            let initialD = dRegister(code, zero, clock)
            
            let aOrM = mux16(initialA, mValue, isMCode)
            
            let initialALU = compute(x: initialD,
                                     y: aOrM,
                                     code: aluCode)
            
            let shouldWriteA = shouldAct(destination[0])
            let shouldWriteD = shouldAct(destination[1])
            let shouldWriteM = shouldAct(destination[2])
            
            let finalD = dRegister(initialALU.out,
                                   shouldWriteD,
                                   clock)
            
            let finalALU = compute(x: finalD,
                                   y: aOrM,
                                   code: aluCode)
            
            let finalA = aRegister(finalALU.out,
                                   shouldWriteA,
                                   clock)
            
            let negJumpBit = and(finalALU.ng,
                                 jump[0])
            let zerJumpBit = and(finalALU.zr,
                                 jump[1])
            let posJumpBit = and(and(not(finalALU.ng),
                                     not(finalALU.zr)),
                                 jump[2])
            
            let shouldJump = shouldAct(or(or(negJumpBit,
                                             posJumpBit),
                                          zerJumpBit))
            
            let shouldInc = shouldAct(and(not(shouldJump),
                                          not(shouldReset)))
            
            let pcValue = pcRegister(finalA,
                                     shouldReset,
                                     shouldJump,
                                     shouldInc,
                                     clock)
                        
            return Out(mValue: finalALU.out,
                       shouldWrite: shouldWriteM,
                       aValue: finalA,
                       pcValue: pcValue)
        }
        
        return either(lhs: setA(),
                      or: computeCode(),
                      basedOn: isComputation)
    }
    
    func either(
        lhs: @autoclosure () -> (CPU.Out),
        or rhs: @autoclosure () -> (CPU.Out),
        basedOn pred: Char
    ) -> CPU.Out {
        let lhs = lhs()
        let rhs = rhs()
        
        return CPU.Out(mValue: mux16(lhs.mValue,
                                     rhs.mValue,
                                     pred),
                       shouldWrite: mux(lhs.shouldWrite,
                                        rhs.shouldWrite,
                                        pred),
                       aValue: mux16(lhs.aValue,
                                     rhs.aValue,
                                     pred),
                       pcValue: mux16(lhs.pcValue,
                                      rhs.pcValue,
                                      pred)
        )
    }
    
    private func compute(
        x: String,
        y: String,
        code: String
    ) -> (out: String, zr: Char, ng: Char) {
        alu(x: x,
            y: y,
            zx: code[0],
            nx: code[1],
            zy: code[2],
            ny: code[3],
            f: code[4],
            no: code[5])
    }
}

class FastCPU: CPU {
    override func either(
        lhs: @autoclosure () -> (CPU.Out),
        or rhs: @autoclosure () -> (CPU.Out),
        basedOn pred: Char
    ) -> CPU.Out {
        pred == "0" ? lhs() : rhs()
    }
}

extension Register16 {
    var value: String {
        self(0.b, "0", "0")
    }
}
