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
    }
    
    let a = Register()
    let d = Register()
    let pc = PC()
    
    private let null = "*******"

    
    func callAsFunction(
        _ input: String,
        _ instruction: String,
        _ reset: Char,
        _ clock: Char
    ) -> Out {
        if instruction[0] == "0" {
            let value = String(instruction.dropFirst())
            let aValue = a(value, "1", clock)
            let pcValue = pc("0".toBinary(), "0", "0", "1", clock)
            
            return Out(toMemory: null,
                       shouldWrite: "0",
                       aValue: aValue,
                       pcValue: pcValue)
        } else {
            let instruction = String(instruction.dropFirst(3))
            
            let aValue = a("0".toBinary(15), "0", clock)
            let dValue = d("0".toBinary(15), "0", clock)

            let aOrMValue = instruction[0] == "0"
                ? aValue
                : input
            
            let aluOut = alu(x: dValue,
                             y: aOrMValue,
                             zx: instruction[1],
                             nx: instruction[2],
                             zy: instruction[3],
                             ny: instruction[4],
                             f: instruction[5],
                             no: instruction[6]).out
            
            let shouldWriteM = instruction[9]
            let toMemory = shouldWriteM == "0" ? null : aluOut
            let pcValue = pc("0".toBinary(), "0", "0", "1", clock)
            
            let shouldWriteD = instruction[8]
            let shouldWriteA = instruction[7]
            
            let _ = d(aluOut, shouldWriteD, clock)
            
            return Out(toMemory: toMemory,
                       shouldWrite: shouldWriteM,
                       aValue: a(aluOut, shouldWriteA, clock),
                       pcValue: pcValue)
        }
    }
}
