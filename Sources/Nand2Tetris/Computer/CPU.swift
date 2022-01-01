final class CPU {
    struct Out: Equatable {
        let mValue: String
        let shouldWrite: Char
        let aValue: String
        let pcValue: String
        
        func or(_ other: Out, predicate pred: Char) -> Out {
            Out(mValue: or(mValue, other.mValue, pred),
                shouldWrite: mux(shouldWrite, other.shouldWrite, pred),
                aValue: or(aValue, other.aValue, pred),
                pcValue: or(pcValue, other.pcValue, pred)
            )
        }
        
        private func or(
            _ lhs: String,
            _ rhs: String,
            _ pred: Char
        ) -> String {
            mux16(lhs.leftPad(16), rhs.leftPad(16), pred)
        }
    }
    
    let aRegister = Register()
    let dRegister = Register()
    let pcRegister = PC()
    
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
        
        return setA().or(computeCode(), predicate: isComputation)
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
