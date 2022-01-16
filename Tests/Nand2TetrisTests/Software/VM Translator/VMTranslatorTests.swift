import XCTest
@testable import Nand2Tetris

class VMTranslatorTests: XCTestCase {
    var translator: VMTranslator!
    
    override func setUp() {
        translator = VMTranslator()
    }
    
    func translate(_ vmCode: String) -> String {
        translator.translate(vmCode)
    }
    
    func generateConstant(_ c: String) -> String {
        """
        @\(c)
        D=A
        @SP
        A=M
        M=D
        @SP
        M=M+1
        """
    }
    
    func testPushConstants() {
        let vmCode =
                    """
                    push constant 17
                    push constant 22
                    """
        let assembly =
                    """
                    \(generateConstant("17"))
                    \(generateConstant("22"))
                    """
        translate(vmCode) => assembly
    }
    
    func generateArithmetic(_ sign: String) -> String {
        let dCommand = sign == "-"
        ? "D=M\(sign)D"
        : "D=D\(sign)M"
        
        return """
        @SP
        A=M-1
        D=M
        @SP
        M=M-1
        A=M-1
        \(dCommand)
        @SP
        A=M-1
        M=D
        """
    }
    
    func testAdd() {
        translate("add") => generateArithmetic("+")
    }
    
    func testSub() {
        translate("sub") => generateArithmetic("-")
    }
    
    func testAnd() {
        translate("and") => generateArithmetic("&")
    }
    
    func testOr() {
        translate("or") => generateArithmetic("|")
    }
    
    func generateUnary(_ sign: String) -> String {
        """
        @SP
        A=M-1
        M=\(sign)M
        @SP
        A=M-1
        M=D
        """
    }
    
    func testNot() {
        translate("not") => generateUnary("!")
    }
    
    func testNeg() {
        translate("neg") => generateUnary("-")
    }
    
    func generateConditional(_ code: String) -> String {
        """
        @SP
        A=M-1
        D=M
        @SP
        M=M-1
        A=M-1
        D=M-D
        @SP
        A=M-1
        M=D
        @\(code + "_TRUE")
        D;J\(code.prefix(2))
        D=-1
        @SP
        A=M-1
        M=D
        @\(code + "_FALSE")
        0;JMP
        (\(code + "_TRUE"))
        D=0
        @SP
        A=M-1
        M=D
        (\(code + "_FALSE"))
        """
    }
    
    func testEQ() {
        translate("eq") => generateConditional("EQ0")
    }
    
    func testGT() {
        translate("gt") => generateConditional("GT0")
    }
    
    func testLT() {
        translate("lt") => generateConditional("LT0")
    }
    
    func testChainedConditionals() {
        translate("lt\nlt") =>
        (generateConditional("LT0") + "\n" + generateConditional("LT1"))
    }
}

class VMTranslatorAcceptanceTests: ComputerTestCase {
    var translator: VMTranslator!
    var assembler: Assembler!
    
    override func setUp() {
        super.setUp()
        translator = VMTranslator()
        assembler = Assembler()
        executionTime = 150000
        c.memory(256.b, "1", 0.b, "1")
    }
    
    func assert(d: Int, sp: Int = 257, top: Int? = nil) {
        XCTAssertEqual(String(d), dRegister, "D Register")
        XCTAssertEqual(String(sp), stackPointer, "Stack Pointer")
        XCTAssertEqual(String(top ?? d), memory(256), "Memory 256")
    }
    
    var dRegister: String {
        c.cpu.dRegister.value.toDecimal()
    }
    
    var stackPointer: String {
        c.memory.value(0.b).toDecimal()
    }
    
    func memory(_ i: Int) -> String {
        c.memory.value(i.b).toDecimal()
    }
    
    func translated(_ vmCode: String) -> [String] {
        assembler.assemble(
            translator.translate(
                vmCode)
        )
    }
    
    func testAdd2And3() {
        let add2And3 =
                    """
                    push constant 2
                    push constant 3
                    add
                    """

        runProgram(translated(add2And3))
        assert(d: 5)
    }
    
    func testSubtract2From3() {
        let sub2From3 =
                    """
                    push constant 3
                    push constant 2
                    sub
                    """

        runProgram(translated(sub2From3))
        assert(d: 1)
    }
    
    func testChainedAddition() {
        let add2And2And3 =
                    """
                    push constant 2
                    push constant 2
                    push constant 3
                    add
                    add
                    """

        runProgram(translated(add2And2And3))
        assert(d: 7)
    }
    
    func testNotEqual() {
        let notEqual =
                    """
                    push constant 2
                    push constant 1
                    eq
                    """
        
        runProgram(translated(notEqual))
        assert(d: -1)
    }
    
    func testEqual() {
        let equal =
                    """
                    push constant 2
                    push constant 2
                    eq
                    """
        
        runProgram(translated(equal))
        assert(d: 0)
    }
    
    func testLessThan() {
        let lt =
                """
                push constant 2
                push constant 3
                lt
                """
        
        runProgram(translated(lt))
        assert(d: 0)
    }
    
    func testNotLessThan() {
        let lt =
                """
                push constant 3
                push constant 2
                lt
                """
        
        runProgram(translated(lt))
        assert(d: -1)
    }
}

/// Specs:
///
/// Memory access commands:
///
/// (but how do you decide what to initialise the base address to?)
///
/// local
/// argument
/// this
/// that
/// pointer
/// temp
/// static
///
/// Ram:
///
/// 0-15 -> Virtual Regsters
/// 16-255 -> Static Vars (auto generated by assembly)
/// 256-2047 -> Stack
/// 2048-16483 -> Heap
/// 16384-24575 -> IO
///
/// Predefined assembly addresses corresponding to VM memory access:
///
/// SP -> Stack Pointer -> RAM[0]
/// LCL -> Local Pointer -> RAM[1]
/// ARG -> Argument Pointer -> RAM[2]
/// THIS -> This pointer -> RAM[3]
/// THAT -> That pointer -> RAM[4]
/// RAM[5-12] -> Temp segment
/// RAM[13-15] -> General purpose registers
