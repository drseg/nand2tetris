/**
 The Hack CPU (Central Processing unit), consisting of an ALU, two registers named A and D, and a program counter named PC.
 
 The D and A in the language specification refer to CPU-resident registers, while M refers to the external memory location addressed by A, i.e. to Memory[A].
 
 The inM input holds the value of this location. If the current instruction needs to write a value to M, the value is placed in outM, the address of the target location is placed in the addressM output, and the writeM control bit is asserted. (When writeM == 0, any value may appear in outM).
 
 The outM and writeM outputs are combinational: they are affected instantaneously by the execution of the current instruction. The addressM and pc outputs are clocked: although they are affected by the execution of the current instruction, they commit to their new values only in the next time step. If reset==1 then the CPU jumps to address 0 (i.e. pc is set to 0 in next time step) rather than to the address resulting from executing the current instruction.
 
    IN        inM[16]               // contents of Memory[A]
         instruction[16]    // contents of ROM[A]
         reset                     // Signals whether to re-start the current program (reset==1) or continue                                          executing the current program (reset==0).

    OUT    outM[16]            // value to connect to Memory[A] }
         writeM                  // Write to M?                                   } to data memory
         addressM[15]    // Address in data memory (of M)    }
 
         pc[15]                // address of next instruction           } to instruction memory

Instruction format:

0 vvvvvvvvvvvvvvvv:
 
   A = value

111 a cccccc ddd jjj:
 
   a specifies how to use the A register
        0: value of A,
        1: value of M[A]
 
   cccccc are the ALU inputs
 
   ddd are where to store the ALU output
        null, M (refers to M[A]), D, MD, A, AM, AD, AMD
 
   jjj specify a PC jump if needed
        null, JGT, JEQ, JGE, JLT, JNE, JLE, JMP (unconditional)
 
 CPU has inside:
 
 D register
 A register
 PC register
 ALU
 */

final class CPU {
    struct Out: Equatable {
        let toMemory: String
        let shouldWrite: Char
        let aValue: String
        let pcValue: String
        
        func or(_ other: Out, predicate: Char) -> Out {
            Out(toMemory: mux16(toMemory.leftPad(16),
                                other.toMemory.leftPad(16),
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
        
        func setA() -> Out {
            let aValue = a(code, not(isComputation), clock)
            let pcValue = pc(aValue,
                             "0",
                             "0",
                             not(isComputation),
                             clock)
            
            return Out(toMemory: aValue,
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
            
            let initialAValue = a(code, "0", clock)
            let initialDValue = d(code, "0", clock)
            
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
            
            return Out(toMemory: finalALU.out,
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
