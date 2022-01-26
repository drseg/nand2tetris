import XCTest
@testable import Nand2Tetris

class VMTranslatorTestCase: ComputerTestCase {
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
    
    func runProgram(_ vmProgram: String, cycles: Int? = nil, useFastClocking: Bool = true) {
        runProgram(toBinary(vmProgram),
                   useFastClocking: useFastClocking,
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
        translated = translated(vmCode)
        assembly = resolved(translated)
        binary = assembler.toBinary(translated)
        
        return binary
    }
    
    func translated(_ vmCode: String) -> String {
        VMTranslator().toAssembly(vmCode)
    }
    
    func resolved(_ assembly: String) -> String {
        let resolver = SymbolResolver()
        let cleaner = AssemblyCleaner()
        return resolver.resolving(cleaner.clean(assembly))
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
}

class VMTranslatorAcceptanceTests: VMTranslatorTestCase {
    func testEmptyProgramSetsSP() {
        runProgram("")
        assertResult(d: 256, sp: 256)
    }
    
    func testPushNegativeConstant() {
        runProgram("push constant -1")
        assertResult(d: -1)
    }
    
    func testRemovesComments() {
        let uncommented = translated(
                            """
                            push constant 1
                            push constant 3
                            """
        )
        let commented = translated(
                """
                push constant 1
                //push constant 2
                push constant 3
                """
        )
        
        commented => uncommented
    }
    
    func testRemovesLeadingTrailingWhitespaces() {
        let withWhite = translated("   push constant -1  ")
        let withoutWhite = translated("push constant -1")
        
        withWhite => withoutWhite
    }
    
    func testRemovesMultiSpaces() {
        let withMulti = translated("push   constant  -1")
        let withoutMulti = translated("push constant -1")
        
        withMulti => withoutMulti
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
}

class VMFunctionTests: VMTranslatorTestCase {
    func log(verbose: Bool = false, upto max: Int = 280, width: Int = 80) {
        func sectionBreak() {
            print(String(repeating: "-", count: width))
        }
        
        if verbose {
            sectionBreak()
            print(assembly)
            sectionBreak()
            print(translated)
        }
        
        sectionBreak()
        print("SP: \(memory(SP))")
        print("LCL: \(memory(LCL))")
        print("ARG: \(memory(ARG))")
        print("THIS: \(memory(THIS))")
        print("THAT: \(memory(THAT))")
        sectionBreak()
        (256...max).forEach {
            print("M[\($0)]: \(memory($0))")
        }
        sectionBreak()
        print("R13: \(memory(13))")
        print("R14: \(memory(14))")
        sectionBreak()
    }
    
    func assertSegmentsReturnedToDefault() {
        memory(THAT) => String(defaultTHAT)
        memory(THIS) => String(defaultTHIS)
        memory(ARG) => String(defaultARG)
        memory(LCL) => String(defaultLCL)
    }
    
    func assertStack(incrementedBy offset: Int, repeating value: String) {
        (defaultSP...(defaultSP + offset - 1)).forEach {
            memory($0) => value
        }
        memory(defaultSP + offset) !=> value
        memory(SP) => String(defaultSP + offset)
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
        let argCount = 0
        
        runProgram(
                    """
                    call Test.add \(argCount)
                    """
        )
        
        log()
        
        memory(defaultSP) => "93" // return address
        memory(257) => String(defaultLCL)
        memory(258) => String(defaultARG)
        memory(259) => String(defaultTHIS)
        memory(260) => String(defaultTHAT)

        memory(ARG) => String(defaultSP - argCount)
        memory(LCL) => String(defaultSP + 5)
    }
    
    func testCallReturn() {
        runProgram("""
                    call Test.test 0
                    function Test.test 0
                    push constant 99
                    return
                    """
        )
        
        assertStack(incrementedBy: 1, repeating: "99")
        assertSegmentsReturnedToDefault()
    }
    
    func testMultiCallReturn() {
        runProgram("""
                    call Test.test 0
                    call Test.test 0
                    call Test.test 0
                    label LOOP
                    goto LOOP
                    function Test.test 0
                    push constant 99
                    return
                    """
                    , cycles: 500)
        
        assertStack(incrementedBy: 3, repeating: "99")
        assertSegmentsReturnedToDefault()
    }
    
    func testFunctionWithNoArgs() {
        runProgram(
        """
        call Test.main 0
        push constant 7777
        push constant 8888
        label LOOPY
        goto LOOPY
                    
        function Test.main 0
        push constant 1
        return
        """)
        
        memory(256) => "1"
        memory(257) => "7777"
        memory(258) => "8888"
    }
    
    func testFunctionWithOneArg() {
        runProgram(
        """
        push constant 9
        
        call Test.inc 1
        push constant 7777
        push constant 8888
        label LOOPY
        goto LOOPY
                    
        function Test.inc 0
        push argument 0
        push constant 1
        add
        return
        """
        )
        
        memory(256) => "10"
        memory(257) => "7777"
        memory(258) => "8888"
    }
    
    func testFunctionWithTwoArgs() {
        runProgram(
        """
        push constant 9
        push constant 1
        
        call Test.inc 2
        push constant 7777
        push constant 8888
        label LOOPY
        goto LOOPY
                    
        function Test.inc 0
        push argument 0
        push argument 1
        add
        return
        """
        )
        
        memory(256) => "10"
        memory(257) => "7777"
        memory(258) => "8888"
    }
    
    func testFibonacci() {
        let fib =
        """
        push constant 3
        call Main.fibonacci 1
        push constant 7777
        push constant 8888
        label LOOPY
        goto LOOPY

        function Main.fibonacci 0
        push argument 0
        push constant 2
        lt
        if-goto IF_TRUE
        goto IF_FALSE
        label IF_TRUE
        push argument 0
        return
        label IF_FALSE
        push argument 0
        push constant 2
        sub
        call Main.fibonacci 1
        push argument 0
        push constant 1
        sub
        call Main.fibonacci 1
        add
        return
        """

        runProgram(fib, cycles: 1400)
        memory(256) => "2"
        memory(257) => "7777"
        memory(258) => "8888"
    }
}
