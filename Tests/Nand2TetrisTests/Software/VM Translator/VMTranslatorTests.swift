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
        initialiseMemory()
    }

    func initialiseMemory() {
        c.memory(sp.b, "1", 0.b, "1")
        c.memory(lcl.b, "1", 1.b, "1")
        c.memory(arg.b, "1", 2.b, "1")
        c.memory(this.b, "1", 3.b, "1")
        c.memory(that.b, "1", 4.b, "1")
    }
    
    func runProgram(_ vmProgram: String) {
        runProgram(translated(vmProgram), useFastClocking: true)
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
        let translated = translator.toAssembly(vmCode)
        assembly = resolver.resolvingSymbols(in: translated)
        binary = assembler.toBinary(assembly)
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
        runProgram("push constant -1")
        assertResult(d: -1)
    }
    
    func testPushManyConstants() {
        let push =
                """
                push constant 2
                push constant 3
                push constant 4
                push constant 5
                """
        runProgram(push)
        assertResult(d: 5, sp: 260)
    }
    
    func testAdd2And3() {
        let add2And3 =
                    """
                    push constant 2
                    push constant 3
                    add
                    """

        runProgram(add2And3)
        assertResult(d: 5)
    }
    
    func testSubtract2From3() {
        let sub2From3 =
                    """
                    push constant 3
                    push constant 2
                    sub
                    """

        runProgram(sub2From3)
        assertResult(d: 1)
    }
    
    func testSubtract3From2() {
        let sub3From2 =
                    """
                    push constant 2
                    push constant 3
                    sub
                    """
        runProgram(sub3From2)
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
        runProgram(add2And2And3)
        assertResult(d: 7)
    }
    
    func testEqual() {
        let equal =
                    """
                    push constant 2
                    push constant 2
                    eq
                    """
        runProgram(equal)
        assertResult(d: 0)
    }
    
    func testNotEqual() {
        let notEqual =
                    """
                    push constant 2
                    push constant 1
                    eq
                    """
        runProgram(notEqual)
        assertResult(d: -1)
    }
    
    func testLessThan() {
        let lt =
                """
                push constant 2
                push constant 3
                lt
                """
        runProgram(lt)
        assertResult(d: 0)
    }
    
    func testNotLessThan() {
        let notLT =
                """
                push constant 3
                push constant 2
                lt
                """
        runProgram(notLT)
        assertResult(d: -1)
    }
    
    func testGreaterThan() {
        let gt =
                """
                push constant 3
                push constant 2
                gt
                """
        runProgram(gt)
        assertResult(d: 0)
    }
    
    func testNotGreaterThan() {
        let notGT =
                """
                push constant 2
                push constant 3
                gt
                """
        runProgram(notGT)
        assertResult(d: -1)
    }
    
    func testNegative() {
        let neg =
                """
                push constant 1
                neg
                """
        runProgram(neg)
        assertResult(d: -1)
    }
    
    func testDoubleNegative() {
        let neg =
                """
                push constant -1
                neg
                """
        runProgram(neg)
        assertResult(d: 1)
    }
    
    func testOtherDoubleNegative() {
        let neg =
                """
                push constant 1
                neg
                neg
                """
        runProgram(neg)
        assertResult(d: 1)
    }
    
    func testNot() {
        let not =
                """
                push constant -1
                not
                """
        runProgram(not)
        assertResult(d: 0)
    }
    
    func testDoubleNot() {
        let not =
                """
                push constant -1
                not
                not
                """
        runProgram(not)
        assertResult(d: -1)
    }
    
    func testAnd() {
        let and =
                """
                push constant 0
                push constant -1
                and
                """
        runProgram(and)
        assertResult(d: 0)
    }
    
    func testOr() {
        let or =
                """
                push constant 0
                push constant -1
                or
                """
        runProgram(or)
        assertResult(d: -1)
    }
    
    func assertPopped(
        _ segment: String,
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
        
        runProgram(pop)
        
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
    
    func testPopLocal() {
        assertPopped("local", toFirst: lcl)
    }
    
    func testPopArgument() {
        assertPopped("argument", toFirst: arg)
    }
    
    func testPopThis() {
        assertPopped("this", toFirst: this)
    }
    
    func testPopThat() {
        assertPopped("that", toFirst: that)
    }
    
    func testPopTemp() {
        assertPopped("temp", toFirst: temp)
    }
    
    func testPopPointer() {
        assertPopped("pointer", toFirst: ptr0, toSecond: ptr1)
    }
    
    func testPopStatic() {
        assertPopped("static", toFirst: 16)
    }
    
    func assertPushAndPop(
        _ segment: String,
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
        runProgram(pushAndPop)
        
        XCTAssertEqual(String(sp),
                       stackPointer,
                       "Stack Pointer")
        XCTAssertEqual(String(19),
                       memory(toFirst),
                       "Memory[\(toFirst)]")
    }
    
    func testPushLocal() {
        assertPushAndPop("local", toFirst: lcl)
    }
    
    func testPushArgument() {
        assertPushAndPop("argument", toFirst: arg)
    }
    
    func testPushThis() {
        assertPushAndPop("this", toFirst: this)
    }
    
    func testPushThat() {
        assertPushAndPop("that", toFirst: that)
    }
    
    func testPushTemp() {
        assertPushAndPop("temp", toFirst: temp)
    }
    
    func testPushPointer() {
        assertPushAndPop("pointer", toFirst: ptr0)
    }
    
    func testPushStatic() {
        assertPushAndPop("static", toFirst: 16)
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
        runProgram(goto)
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
        runProgram(ifGotoTrue)
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
        runProgram(ifGotoFalse)
        assertResult(d: 6, sp: 257)
    }
}

/// Function commands:
///
/// function
/// call
/// return
