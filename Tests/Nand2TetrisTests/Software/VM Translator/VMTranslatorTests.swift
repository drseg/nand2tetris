import XCTest
@testable import Nand2Tetris

class VMTranslatorAcceptanceTests: ComputerTestCase {
    let sp = 256
    let lcl = 1000
    let arg = 1250
    let this = 1500
    let that = 1750
    
    var translator: VMTranslator!
    var assembler: Assembler!
    
    var assembly = ""
    var binary = [String]()
    
    override func setUp() {
        super.setUp()
        translator = VMTranslator()
        assembler = Assembler()
        executionTime = 150000
        
        initialiseStack()
    }
    
    func initialiseStack() {
        c.memory(sp.b, "1", 0.b, "1")
        c.memory(lcl.b, "1", 1.b, "1")
        c.memory(arg.b, "1", 2.b, "1")
        c.memory(this.b, "1", 3.b, "1")
        c.memory(that.b, "1", 4.b, "1")
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
    
    func assertPopped(
        segment: String,
        to: Int,
        sp: Int = 256
    ) {
        let pop =
                """
                push constant 9
                pop \(segment) 0
                """
        
        runProgram(translated(pop))
        
        XCTAssertEqual(String(sp),
                       stackPointer,
                       "Stack Pointer")
        XCTAssertEqual(String(9),
                       memory(to),
                       "Memory[\(to)]")
    }
    
    func assertPushAndPop(
        segment: String,
        to: Int,
        sp: Int = 256
    ) {
        let pushAndPop =
                    """
                    push constant 9
                    push constant 10
                    pop \(segment) 0
                    pop \(segment) 1
                    push \(segment) 0
                    push \(segment) 1
                    add
                    pop \(segment) 0
                    """
        
        runProgram(translated(pushAndPop))
        
        XCTAssertEqual(String(sp),
                       stackPointer,
                       "Stack Pointer")
        XCTAssertEqual(String(19),
                       memory(to),
                       "Memory[\(to)]")
    }
    
    func testPopLocal() {
        assertPopped(segment: "local", to: lcl)
    }
    
    func testPopArgument() {
        assertPopped(segment: "argument", to: arg)
    }
    
    func testPopThis() {
        assertPopped(segment: "this", to: this)
    }
    
    func testPopThat() {
        assertPopped(segment: "that", to: that)
    }
    
//    func testPushLocal() {
//        assertPushAndPop(segment: "local", to: VMTranslator.lcl)
//    }
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
///
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
