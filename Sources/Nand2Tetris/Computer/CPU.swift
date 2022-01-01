final class CPU {
    struct Out: Equatable {
        let mValue: String
        let shouldWrite: Char
        let aValue: String
        let pcValue: String
        
        func or(_ other: Out, predicate: Char) -> Out {
            Out(mValue: mux16(mValue.leftPad(16),
                              other.mValue.leftPad(16),
                              predicate),
                shouldWrite: mux(shouldWrite,
                                 other.shouldWrite,
                                 predicate),
                aValue: mux16(aValue.leftPad(16),
                              other.aValue.leftPad(16),
                              predicate),
                pcValue: mux16(pcValue.leftPad(16),
                               other.pcValue.leftPad(16),
                               predicate)
            )
        }
    }
    
    let a = Register()
    let d = Register()
    let pc = PC()
    
    func callAsFunction(
        _ mValue: String,
        _ code: String,
        _ shouldReset: Char,
        _ clock: Char
    ) -> Out {
        let isComputation = code[0]
        let zero = xor(isComputation, isComputation)
        
        func setA() -> Out {
            let aValue = a(code, not(isComputation), clock)
            let pcValue = pc(aValue,
                             zero,
                             zero,
                             not(isComputation),
                             clock)
            
            return Out(mValue: aValue,
                       shouldWrite: isComputation,
                       aValue: aValue,
                       pcValue: pcValue)
        }
        
        func computeCode() -> Out {
            func shouldAct(_ bit: Char) -> Char {
                and(bit, isComputation)
            }
            
            let isMCode = code[3]
            let aluCode = String(code.dropFirst(4).prefix(6))
            let destination = String(code.dropFirst(10).prefix(3))
            let jump = String(code.dropFirst(13))
            
            let initialAValue = a(code, zero, clock)
            let initialDValue = d(code, zero, clock)
            
            let aOrMValue = mux16(initialAValue, mValue, isMCode)
            
            let initialALU = compute(x: initialDValue,
                                     y: aOrMValue,
                                     code: aluCode)
            
            let shouldWriteA = shouldAct(destination[0])
            let shouldWriteD = shouldAct(destination[1])
            let shouldWriteM = shouldAct(destination[2])
            
            let finalDValue = d(initialALU.out,
                                shouldWriteD,
                                clock)
            
            let finalALU = compute(x: finalDValue,
                                   y: aOrMValue,
                                   code: aluCode)
            
            let finalAValue = a(finalALU.out,
                                shouldWriteA,
                                clock)
            
            let negJumpBit = and(finalALU.ng,
                                 jump[0])
            let zerJumpBit = and(finalALU.zr,
                                 jump[1])
            let posJumpBit = and(and(not(finalALU.ng),
                                     not(finalALU.zr)),
                                 jump[2])
            
            let shouldJump = shouldAct(
                or(or(negJumpBit,
                      posJumpBit),
                   zerJumpBit
                  )
            )
            
            let shouldInc = shouldAct(and(not(shouldJump),
                                          not(shouldReset)))
            
            let pcValue = pc(finalAValue,
                             shouldReset,
                             shouldJump,
                             shouldInc,
                             clock)
            
            return Out(mValue: finalALU.out,
                       shouldWrite: shouldWriteM,
                       aValue: finalAValue,
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
