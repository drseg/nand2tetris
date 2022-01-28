import XCTest
@testable import Nand2Tetris

class VMTranslatorTests: ComputerTestCase {
    let SP = 0,
        LCL = 1,
        ARG = 2,
        THIS = 3,
        THAT = 4
    
    let defaultSP = 256,
        defaultLCL = 1000,
        defaultARG = 1250,
        defaultTHIS = 1500,
        defaultTHAT = 1750
    
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
        cpu = FastCPU(aRegister: FastRegister(),
                      dRegister: FastRegister(),
                      pcRegister: PC(register: FastRegister()))
        computer.cpu = cpu
        translator = VMTranslator()
        assembler = Assembler()
        initialiseMemory()
    }

    func initialiseMemory() {
        computer.memory(defaultLCL.b, "1", LCL.b, "1")
        computer.memory(defaultARG.b, "1", ARG.b, "1")
        computer.memory(defaultTHIS.b, "1", THIS.b, "1")
        computer.memory(defaultTHAT.b, "1", THAT.b, "1")
    }
    
    func runProgramFromFiles(_ files: [VMFile]) {
        runProgram(toBinary(files), useFastClocking: true)
    }
    
    func runProgram(
        _ vmProgram: String,
        useFastClocking: Bool = true,
        cycles: Int? = nil,
        file: String = #fileID
        
    ) {
        runProgram(toBinary(vmProgram, file: file),
                   useFastClocking: useFastClocking,
                   cycles: cycles)
    }
    
    var dRegister: String {
        computer.cpu.dRegister.value.toDecimal()
    }
    
    var stackPointer: String {
        computer.memory.value(0.b).toDecimal()
    }
    
    func memory(_ i: Int) -> String {
        computer.memory.value(i.b).toDecimal()
    }
    
    @discardableResult
    func toBinary(_ vmCode: String, file: String = #fileID) -> [String] {
        toBinary([VMFile(name: file, code: vmCode)])
    }
    
    @discardableResult
    func toBinary(_ files: [VMFile]) -> [String] {
        translated = translator.toAssembly(files)
        assembly += resolved(translated)
        binary += assembler.toBinary(translated)
        
        return binary
    }
    
    func translated(_ vmCode: String, file: String = #fileID) -> String {
        translated([VMFile(name: file, code: vmCode)])
    }
    
    func translated(_ files: [VMFile]) -> String {
        VMTranslator().toAssembly(files)
    }
    
    func resolved(_ assembly: String) -> String {
        SymbolResolver().resolving(
            AssemblyCleaner().clean(assembly)
        )
    }
    
    func log(
        verbose: Bool = false,
        upto max: Int = 280,
        width: Int = 80
    ) {
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
    
    func testRemovesComments() {
        let uncommented = translated(
        """
        push constant 1
        push constant 3
        """)
        let commented = translated(
        """
        push constant 1
        //push constant 2
        push constant 3
        """)
        
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
        runProgram(
        """
        push constant 2
        push constant 3
        push constant 4
        push constant 5
        """)
        assertResult(d: 5, sp: 260)
    }
    
    func testAdd2And3() {
        runProgram(
        """
        push constant 2
        push constant 3
        add
        """)
        assertResult(d: 5)
    }
    
    func testSubtract2From3() {
        runProgram(
        """
        push constant 3
        push constant 2
        sub
        """)
        assertResult(d: 1)
    }
    
    func testSubtract3From2() {
        runProgram(
        """
        push constant 2
        push constant 3
        sub
        """)
        assertResult(d: -1)
    }
    
    func testChainedAddition() {
        runProgram(
        """
        push constant 2
        push constant 2
        push constant 3
        add
        add
        """)
        assertResult(d: 7)
    }
    
    func testEqual() {
        runProgram(
        """
        push constant 2
        push constant 2
        eq
        """)
        assertResult(d: 0)
    }
    
    func testNotEqual() {
        runProgram(
        """
        push constant 2
        push constant 1
        eq
        """)
        assertResult(d: -1)
    }
    
    func testLessThan() {
        runProgram(
        """
        push constant 2
        push constant 3
        lt
        """)
        assertResult(d: 0)
    }
    
    func testNotLessThan() {
        runProgram(
        """
        push constant 3
        push constant 2
        lt
        """)
        assertResult(d: -1)
    }
    
    func testGreaterThan() {
        runProgram(
        """
        push constant 3
        push constant 2
        gt
        """)
        assertResult(d: 0)
    }
    
    func testNotGreaterThan() {
        runProgram(
        """
        push constant 2
        push constant 3
        gt
        """)
        assertResult(d: -1)
    }
    
    func testNegative() {
        runProgram(
        """
        push constant 1
        neg
        """)
        assertResult(d: -1)
    }
    
    func testDoubleNegative() {
        runProgram(
        """
        push constant -1
        neg
        """)
        assertResult(d: 1)
    }
    
    func testOtherDoubleNegative() {
        runProgram(
        """
        push constant 1
        neg
        neg
        """)
        assertResult(d: 1)
    }
    
    func testNot() {
        runProgram(
        """
        push constant -1
        not
        """)
        assertResult(d: 0)
    }
    
    func testDoubleNot() {
        runProgram(
        """
        push constant -1
        not
        not
        """)
        assertResult(d: -1)
    }
    
    func testAnd() {
        runProgram(
        """
        push constant 0
        push constant -1
        and
        """)
        assertResult(d: 0)
    }
    
    func testOr() {
        runProgram(
        """
        push constant 0
        push constant -1
        or
        """)
        assertResult(d: -1)
    }
    
    func assertPopped(
        _ segment: String,
        toFirst: Int,
        toSecond: Int? = nil,
        sp: Int = 256
    ) {
        runProgram(
        """
        push constant 9
        push constant 10
        pop \(segment) 0
        pop \(segment) 1
        """)
        
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
        runProgram(
        """
        push constant 9
        push constant 10
        pop \(segment) 0
        pop \(segment) 1
        push \(segment) 0
        push \(segment) 1
        add
        pop \(segment) 0
        """)
        
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
        runProgram(
        """
        goto skip
        push constant 6
        push constant 7
        add
        label skip
        push constant 2
        push constant 3
        add
        """)
        assertResult(d: 5)
    }

    func testIfGotoTrue() {
        runProgram(
        """
        push constant 2
        push constant 3
        lt
        if-goto end
        push constant 6
        label end
        """)
        assertResult(d: 0, sp: 256)
    }
    
    func testIfGotoFalse() {
        runProgram(
        """
        push constant 2
        push constant 3
        gt
        if-goto end
        push constant 6
        label end
        """)
        assertResult(d: 6, sp: 257)
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
        runProgram("function doNothing \(args)")
        memory(0) => String(256 + args)
    }
    
    func testLabelsWithinFunctionFormattedCorrectly() {
        toBinary(
        """
        function test 0
        label TEST
        goto TEST
        if-goto TEST
        """)
        
        translated.components(separatedBy: "(test$TEST)").count => 2
        translated.components(separatedBy: "@test$TEST").count => 3
    }
    
    func testCallFunction() {
        let argCount = Int.random(in: 0...5)
        runProgram("call Test.add \(argCount)")
        
        memory(defaultSP) => "93" // return address
        memory(257) => String(defaultLCL)
        memory(258) => String(defaultARG)
        memory(259) => String(defaultTHIS)
        memory(260) => String(defaultTHAT)

        memory(ARG) => String(defaultSP - argCount)
        memory(LCL) => String(defaultSP + 5)
    }
    
    func testCallReturn() {
        runProgram(
        """
        call Test.test 0
        function Test.test 0
        push constant 99
        return
        """)
        
        assertStack(incrementedBy: 1, repeating: "99")
        assertSegmentsReturnedToDefault()
    }
    
    func testMultiCallReturn() {
        runProgram(
        """
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
        """)
        
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
        """)
        
        memory(256) => "10"
        memory(257) => "7777"
        memory(258) => "8888"
    }
    
    func testFibonacci() {
        runProgram(
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
        """, cycles: 1350)

        memory(256) => "2"
        memory(257) => "7777"
        memory(258) => "8888"
    }
    
    func testMultipleFiles() {
        let f1 =
        """
        call F1.test 0
        label LOOPY
        goto LOOPY
        
        function F1.test 0
        call F2.test 0
        return
        """
        
        let f2 =
        """
        function F2.test 0
        push constant 9999
        return
        """
        
        runProgramFromFiles([VMFile(name: "F1", code: f1),
                             VMFile(name: "F2", code: f2)])
        
        memory(256) => "9999"
    }
    
    func testMultipleFilesWithStaticSegments() {
        let f1 =
        """
        call F1.test 0
        call F2.test 0
        label LOOPY
        goto LOOPY
        
        function F1.test 0
        push constant 9999
        pop static 0
        push static 0
        return
        """
        
        let f2 =
        """
        function F2.test 0
        push constant 8888
        pop static 0
        push static 0
        return
        """
        
        runProgramFromFiles([VMFile(name: "F1", code: f1),
                             VMFile(name: "F2", code: f2)])
        
        memory(256) => "9999"
        memory(257) => "8888"
    }
    
    func testSysInit() {
        translator.sysInit()
        runProgram(
        """
        function Main.main 0
        call Main.test1 0
        call Main.test2 0
        return
        
        function Main.test2 0
        push constant 9999
        return
        
        function Main.test1 0
        push constant 8888
        return
        """
        )
        
        memory(256) => "9999"
    }
}
