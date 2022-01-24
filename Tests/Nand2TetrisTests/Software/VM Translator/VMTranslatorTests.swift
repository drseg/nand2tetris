import XCTest
@testable import Nand2Tetris

class VMTranslatorAcceptanceTests: ComputerTestCase {
    let SP = 0
    let LCL = 1
    let ARG = 2
    let THIS = 3
    let THAT = 4
    
    let defaultSP = 256
    let defaultLCL = 1000
    let defaultARG = 1250
    let defaultTHIS = 1500
    let defaultTHAT = 1750
    
    let temp = 5
    var ptr0: Int { defaultTHIS }
    var ptr1: Int { defaultTHAT }
    
    var translator: VMTranslator!
    var assembler: Assembler!
    var translated = ""
    
    var assembly = ""
    var binary = [String]()
    
    override func setUp() {
        super.setUp()
        translator = VMTranslator()
        assembler = Assembler()
        initialiseMemory()
    }

    func initialiseMemory() {
        c.memory(defaultLCL.b, "1", LCL.b, "1")
        c.memory(defaultARG.b, "1", ARG.b, "1")
        c.memory(defaultTHIS.b, "1", THIS.b, "1")
        c.memory(defaultTHAT.b, "1", THAT.b, "1")
    }
    
    func runProgram(_ vmProgram: String, cycles: Int? = nil) {
        runProgram(toBinary(vmProgram),
                   useFastClocking: true,
                   cycles: cycles)
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
    
    @discardableResult
    func toBinary(_ vmCode: String) -> [String] {
        let resolver = SymbolResolver()
        translated = translator.toAssembly(vmCode)
        assembly = resolver.resolving(translated)
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
    
    func testEmptyProgramSetsSP() {
        runProgram("")
        assertResult(d: 256, sp: 256)
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
        assertPopped("local", toFirst: defaultLCL)
    }
    
    func testPopArgument() {
        assertPopped("argument", toFirst: defaultARG)
    }
    
    func testPopThis() {
        assertPopped("this", toFirst: defaultTHIS)
    }
    
    func testPopThat() {
        assertPopped("that", toFirst: defaultTHAT)
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
        assertPushAndPop("local", toFirst: defaultLCL)
    }
    
    func testPushArgument() {
        assertPushAndPop("argument", toFirst: defaultARG)
    }
    
    func testPushThis() {
        assertPushAndPop("this", toFirst: defaultTHIS)
    }
    
    func testPushThat() {
        assertPushAndPop("that", toFirst: defaultTHAT)
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
    
    func testFunctionDeclarationPushesArgsZeros() {
        let args = Int.random(in: 0...5)
        let function =
                    """
                    function doNothing \(args)
                    """
        runProgram(function)
        memory(0) => String(256 + args)
    }
    
    func testLabelsWithinFunctionFormattedCorrectly() {
        let function =
                    """
                    function doNothing 0
                    label test
                    goto test
                    if-goto test
                    """
        toBinary(function)
        
        translated
            .components(separatedBy: "(doNothing$test)")
            .count => 2
        translated
            .components(separatedBy: "@doNothing$test")
            .count => 3
    }
    
    func testCallFunction() {
        let argCount = Int.random(in: 0...5)
        
        runProgram(
                """
                call Test.add \(argCount)
                """
        )
        
        memory(defaultSP) => "93" // return address
        memory(257) => String(defaultLCL)
        memory(258) => String(defaultARG)
        memory(259) => String(defaultTHIS)
        memory(260) => String(defaultTHAT)
        
        memory(ARG) => String(defaultSP - argCount)
        memory(LCL) => String(defaultSP + 5)
    }
    
    func testReturn() {
        runProgram(
                """
                push constant 99
                return
                """
        )
        
        memory(SP) => String(defaultARG + 1)
        memory(defaultARG) => "99"
        
        memory(THAT) => String(defaultLCL - 1)
        memory(THIS) => String(defaultLCL - 2)
        memory(ARG) => String(defaultLCL - 3)
        memory(LCL) => String(defaultLCL - 4)
        memory(14) => String(defaultLCL - 5)
    }
    
    func testRecursion() {
        runProgram(
                """
                push constant 1
                call Test.add 1
                function Test.add 1
                push argument 0
                push constant 99
                add
                return
                """
                , cycles: 1000)
        
        /// Something's up with the jump/return logic, and perhaps also with setting the return address. How is it actually supposed to work? A function is called by a certain instruction, and a return value is set that I assume should be the next instruction to execute after the return. But what instruction is that?!
        
        print(String(repeating: "-", count: 80))
        print(assembly)
        print(String(repeating: "-", count: 80))
        print(translated)
        print(String(repeating: "-", count: 80))
        print("SP: \(memory(SP))")
        print(String(repeating: "-", count: 80))
        (256...280).forEach {
            print(memory($0))
        }
        print(String(repeating: "*", count: 100))

    }
    
//    func testFibonacci() {
//        let fib = """
//                push constant 9
//                call Main.fibonacci 1
//                function Main.fibonacci 0
//                push argument 0
//                push constant 2
//                lt
//                if-goto IF_TRUE
//                goto IF_FALSE
//                label IF_TRUE
//                push argument 0
//                return
//                label IF_FALSE
//                push argument 0
//                push constant 2
//                sub
//                call Main.fibonacci 1
//                push argument 0
//                push constant 1
//                sub
//                call Main.fibonacci 1
//                add
//                return
//                """
//
//        runProgram(fib, cycles: 1000)
//        assertResult(d: 258, sp: 257, top: 34)
//        (256...500).forEach {
//            print(memory($0))
//        }
//    }
    
    /// todo:
    ///
    /// clean vm, handle comments etc.
    /// consider rewriting VMLine struct as a more accurate data structure
    /// sys code at beginning of assembly files
    /// use acceptance tests from original project
}
