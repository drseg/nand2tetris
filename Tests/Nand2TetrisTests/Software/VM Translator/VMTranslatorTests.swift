import XCTest
@testable import Nand2Tetris

class VMTranslatorAcceptanceTests: ComputerTestCase {
    let sp = 256
    let lcl = 1000
    let arg = 1250
    let this = 1500
    let that = 1750
    let temp = 5
    var ptr0: Int { this }
    var ptr1: Int { that }
    
    var translator: VMTranslator!
    var assembler: Assembler!
    
    var assembly = ""
    var binary = [String]()
    
    override func setUp() {
        super.setUp()
        translator = VMTranslator()
        assembler = Assembler()
        c.usesFastClocking = true
        initialiseMemory()
    }
    
    override func runProgram(
        _ program: [String],
        usingFastClocking: Bool = true
    ) {
        super.runProgram(program, usingFastClocking: usingFastClocking)
    }
    
    func initialiseMemory() {
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
        let resolver = SymbolResolver()
        let translated = translator
            .translateToAssembly(vmCode)
        assembly = resolver.resolvingSymbols(in: translated)
        binary = assembler.assemble(assembly)
        return binary
    }
    
    func assertResult(d: Int, sp: Int = 257, top: Int? = nil) {
        XCTAssertEqual(String(d), dRegister, "D Register")
        XCTAssertEqual(String(sp), stackPointer, "Stack Pointer")
        if sp > 256 {
            XCTAssertEqual(String(top ?? d),
                           memory(sp-1),
                           "Memory \(sp-1)")
        }
    }
    
    func testPushNegativeConstant() {
        runProgram(translated("push constant -1"))
        assertResult(d: -1)
    }
    
    func testPushTwoConstants() {
        let push =
                    """
                    push constant 2
                    push constant 3
                    push constant 4
                    push constant 5
                    """
        
        runProgram(translated(push))
        assertResult(d: 5, sp: 260)
    }
    
    func testAdd2And3() {
        let add2And3 =
                    """
                    push constant 2
                    push constant 3
                    add
                    """

        runProgram(translated(add2And3))
        assertResult(d: 5)
    }
    
    func testSubtract2From3() {
        let sub2From3 =
                    """
                    push constant 3
                    push constant 2
                    sub
                    """

        runProgram(translated(sub2From3))
        assertResult(d: 1)
    }
    
    func testSubtract3From2() {
        let sub3From2 =
                    """
                    push constant 2
                    push constant 3
                    sub
                    """

        runProgram(translated(sub3From2))
        assertResult(d: -1)
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
        assertResult(d: 7)
    }
    
    func testEqual() {
        let equal =
                    """
                    push constant 2
                    push constant 2
                    eq
                    """
        
        runProgram(translated(equal))
        assertResult(d: 0)
    }
    
    func testNotEqual() {
        let notEqual =
                    """
                    push constant 2
                    push constant 1
                    eq
                    """
        
        runProgram(translated(notEqual))
        assertResult(d: -1)
    }
    
    
    func testLessThan() {
        let lt =
                """
                push constant 2
                push constant 3
                lt
                """
        
        runProgram(translated(lt))
        assertResult(d: 0)
    }
    
    func testNotLessThan() {
        let notLT =
                """
                push constant 3
                push constant 2
                lt
                """
        
        runProgram(translated(notLT))
        assertResult(d: -1)
    }
    
    func testGreaterThan() {
        let gt =
                """
                push constant 3
                push constant 2
                gt
                """
        
        runProgram(translated(gt))
        assertResult(d: 0)
    }
    
    func testNotGreaterThan() {
        let notGT =
                """
                push constant 2
                push constant 3
                gt
                """
        
        runProgram(translated(notGT))
        assertResult(d: -1)
    }
    
    func testNegative() {
        let neg =
                """
                push constant 1
                neg
                """
        
        runProgram(translated(neg))
        assertResult(d: -1)
    }
    
    func testDoubleNegative() {
        let neg =
                """
                push constant -1
                neg
                """
        
        runProgram(translated(neg))
        assertResult(d: 1)
    }
    
    func testOtherDoubleNegative() {
        let neg =
                """
                push constant 1
                neg
                neg
                """
        
        runProgram(translated(neg))
        assertResult(d: 1)
    }
    
    func testNot() {
        let not =
                """
                push constant -1
                not
                """
        
        runProgram(translated(not))
        assertResult(d: 0)
    }
    
    func testDoubleNot() {
        let not =
                """
                push constant -1
                not
                not
                """
        
        runProgram(translated(not))
        assertResult(d: -1)
    }
    
    func testAnd() {
        let and =
                """
                push constant 0
                push constant -1
                and
                """
        runProgram(translated(and))
        assertResult(d: 0)
    }
    
    func testOr() {
        let or =
                """
                push constant 0
                push constant -1
                or
                """
        runProgram(translated(or))
        assertResult(d: -1)
    }
    
    func assertPopped(
        segment: String,
        toFirst: Int,
        toSecond: Int? = nil,
        sp: Int = 256
    ) {
        let pop =
                """
                push constant 9
                push constant 10
                pop \(segment) 0
                pop \(segment) 1
                """
        
        runProgram(translated(pop))
        
        XCTAssertEqual(String(sp),
                       stackPointer,
                       "Stack Pointer")
        XCTAssertEqual(String(10),
                       memory(toFirst),
                       "Memory[\(toFirst)]")
        XCTAssertEqual(String(9),
                       memory(toSecond ?? toFirst + 1),
                       "Memory[\(toSecond ?? toFirst + 1)]")
    }
    
    func assertPushAndPop(
        segment: String,
        toFirst: Int,
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
                       memory(toFirst),
                       "Memory[\(toFirst)]")
    }
    
    func testPopLocal() {
        assertPopped(segment: "local", toFirst: lcl)
    }
    
    func testPopArgument() {
        assertPopped(segment: "argument", toFirst: arg)
    }
    
    func testPopThis() {
        assertPopped(segment: "this", toFirst: this)
    }
    
    func testPopThat() {
        assertPopped(segment: "that", toFirst: that)
    }
    
    func testPopTemp() {
        assertPopped(segment: "temp", toFirst: temp)
    }
    
    func testPopPointer() {
        assertPopped(segment: "pointer", toFirst: ptr0, toSecond: ptr1)
    }
    
    func testPopStatic() {
        assertPopped(segment: "static", toFirst: 16)
    }
    
    func testPushLocal() {
        assertPushAndPop(segment: "local", toFirst: lcl)
    }
    
    func testPushArgument() {
        assertPushAndPop(segment: "argument", toFirst: arg)
    }
    
    func testPushThis() {
        assertPushAndPop(segment: "this", toFirst: this)
    }
    
    func testPushThat() {
        assertPushAndPop(segment: "that", toFirst: that)
    }
    
    func testPushTemp() {
        assertPushAndPop(segment: "temp", toFirst: temp)
    }
    
    func testPushPointer() {
        assertPushAndPop(segment: "pointer", toFirst: ptr0)
    }
    
    func testPushStatic() {
        assertPushAndPop(segment: "static", toFirst: 16)
    }
    
    func testLabelAndGoto() {
        let goto =
            """
            goto skip
            push constant 6
            push constant 7
            add
            label skip
            push constant 2
            push constant 3
            add
            """
        runProgram(translated(goto))
        assertResult(d: 5)
    }

    func testIfGotoTrue() {
        let ifGotoTrue =
            """
            push constant 2
            push constant 3
            lt
            if-goto end
            push constant 6
            label end
            """
        runProgram(translated(ifGotoTrue))
        assertResult(d: 0, sp: 256)
    }
    
    func testIfGotoFalse() {
        let ifGotoFalse =
            """
            push constant 2
            push constant 3
            gt
            if-goto end
            push constant 6
            label end
            """
        runProgram(translated(ifGotoFalse))
        assertResult(d: 6, sp: 257)
    }
}

/// Function commands:
///
/// function
/// call
/// return
