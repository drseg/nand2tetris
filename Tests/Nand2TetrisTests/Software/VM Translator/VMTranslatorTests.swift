import XCTest
@testable import Nand2Tetris

class VMTranslatorTests: XCTestCase {
    var translator: VMTranslator!
    
    override func setUpWithError() throws {
        throw XCTSkip()
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
                    push constant -3
                    """
        let assembly =
                    """
                    \(generateConstant("17"))
                    \(generateConstant("22"))
                    \(generateConstant("-3"))
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
    
    var assembly = ""
    var binary = [String]()
    
    override func setUp() {
        super.setUp()
        translator = VMTranslator()
        assembler = Assembler()
        executionTime = 150000
        c.memory(256.b, "1", 0.b, "1")
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
        assembly = translator.translate(vmCode)
        binary = assembler.assemble(assembly)
        return binary
    }

    func assert(d: Int, sp: Int = 257, top: Int? = nil) {
        XCTAssertEqual(String(d), dRegister, "D Register")
        XCTAssertEqual(String(sp), stackPointer, "Stack Pointer")
        XCTAssertEqual(String(top ?? d), memory(256), "Memory 256")
    }
    
    func assertPopped(_ value: Int, to: Int, sp: Int = 256) {
        XCTAssertEqual(String(sp),
                       stackPointer,
                       "Stack Pointer")
        XCTAssertEqual(String(value),
                       memory(to),
                       "Memory[\(to)]")
    }
    
    func testPushNegativeConstant() {
        runProgram(translated("push constant -1"))
        assert(d: -1)
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
    
    func testSubtract3From2() {
        let sub3From2 =
                    """
                    push constant 2
                    push constant 3
                    sub
                    """

        runProgram(translated(sub3From2))
        assert(d: -1)
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
        let notLT =
                """
                push constant 3
                push constant 2
                lt
                """
        
        runProgram(translated(notLT))
        assert(d: -1)
    }
    
    func testGreaterThan() {
        let gt =
                """
                push constant 3
                push constant 2
                gt
                """
        
        runProgram(translated(gt))
        assert(d: 0)
    }
    
    func testNotGreaterThan() {
        let notGT =
                """
                push constant 2
                push constant 3
                gt
                """
        
        runProgram(translated(notGT))
        assert(d: -1)
    }
    
    func testNegative() {
        let neg =
                """
                push constant 1
                neg
                """
        
        runProgram(translated(neg))
        assert(d: -1)
    }
    
    func testDoubleNegative() {
        let neg =
                """
                push constant -1
                neg
                """
        
        runProgram(translated(neg))
        assert(d: 1)
    }
    
    func testOtherDoubleNegative() {
        let neg =
                """
                push constant 1
                neg
                neg
                """
        
        runProgram(translated(neg))
        assert(d: 1)
    }
    
    func testNot() {
        let not =
                """
                push constant -1
                not
                """
        
        runProgram(translated(not))
        assert(d: 0)
    }
    
    func testDoubleNot() {
        let not =
                """
                push constant -1
                not
                not
                """
        
        runProgram(translated(not))
        assert(d: -1)
    }
    
    func testAnd() {
        let and =
                """
                push constant 0
                push constant -1
                and
                """
        runProgram(translated(and))
        assert(d: 0)
    }
    
    func testOr() {
        let or =
                """
                push constant 0
                push constant -1
                or
                """
        runProgram(translated(or))
        assert(d: -1)
    }
    
    func testPopLocal() {
        let popLocal =
                """
                push constant 9
                pop local 0
                """
        
        runProgram(translated(popLocal))
        assertPopped(9, to: VMTranslator.lcl)
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
///
/// 594 each
///
/// 2048-16483 -> Heap
/// 16384-24575 -> IO
///
/// Predefined assembly addresses corresponding to VM memory access:
///
/// SP -> Stack Pointer -> RAM[0] 256+
/// LCL -> Local Pointer -> RAM[1] 1000+
/// ARG -> Argument Pointer -> RAM[2] 1250+
/// THIS -> This pointer -> RAM[3] 1500+
/// THAT -> That pointer -> RAM[4] 1750+
/// RAM[5-12] -> Temp segment
/// RAM[13-15] -> General purpose registers
