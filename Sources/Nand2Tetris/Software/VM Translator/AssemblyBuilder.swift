class AssemblyBuilder {
    private (set) var assembly = ""
    
    func popSegmentWithMnemonic(
        to segment: String,
        at offset: String
    ) {
        append(
        """
        \(setRegister("D", mnemonic: mnemonic(segment), offset: offset))
        @R15
        M=D
        \(popStack())
        @R15
        A=M
        M=D
        """
        )
    }
    
    func popSegmentWithValue(
        to value: String,
        at offset: String
    ) {
        append(
        """
        \(setRegister("D", value: value, offset: offset))
        @R15
        M=D
        \(popStack())
        @R15
        A=M
        M=D
        """
        )
    }
    
    func pushSegmentWithMnemonic(
        _ segment: String,
        at offset: String
    ) {
        append(
        """
        \(setRegister("A", mnemonic: mnemonic(segment), offset: offset))
        D=M
        \(pushDToStack())
        """
        )
    }
    
    func pushSegmentWithValue(
        _ value: String,
        at offset: String
    ) {
        append(
        """
        \(setRegister("A", value: value, offset: offset))
        D=M
        \(pushDToStack())
        """
        )
    }
    
    func pushConstant(_ c: String) {
        c[0] == "-"
        ? pushNegativeConstant(c)
        : pushPositiveConstant(c)
    }
    
    func eq(_ count: String) {
        bool("EQ" + count)
    }
    
    func gt(_ count: String) {
        bool("GT" + count)
    }
    
    func lt(_ count: String) {
        bool("LT" + count)
    }
    
    func add() {
        binaryOperation("+")
    }
    
    func sub() {
        binaryOperation("-")
    }
    
    func and() {
        binaryOperation("&")
    }
    
    func or() {
        binaryOperation("|")
    }
    
    func not() {
        unaryOperation("!")
    }
    
    func neg() {
        unaryOperation("-")
    }
    
    func label(_ label: String) {
        append(
        """
        (\(label))
        """
        )
    }
    
    func goto(_ label: String) {
        append(
        """
        @\(label)
        0;JMP
        """
        )
    }
    
    func ifGoto(_ label: String) {
        append(
        """
        \(popStack())
        @\(label)
        D;JEQ
        """
        )
    }
    
    private func mnemonic(_ segment: String) -> String {
        switch segment {
        case "local":
            return "LCL"
            
        case "argument":
            return "ARG"
            
        case "this":
            return "THIS"
            
        case "that":
            return "THAT"
            
        default:
            fatalError("No mnemonic for segment '\(segment)'")
        }
    }
    
    private func setRegister(
        _ register: String,
        mnemonic: String,
        offset: String = "0"
    ) -> String {
        setWithOffsetAddend(register, mnemonic, offset, "M")
    }
    
    private func setRegister(
        _ register: String,
        value: String,
        offset: String = "0"
    ) -> String {
        setWithOffsetAddend(register, value, offset, "A")
    }
    
    private func setWithOffsetAddend(
        _ register: String,
        _ value: String,
        _ offset: String,
        _ addend: String
    ) -> String {
        """
        @\(offset)
        D=A
        @\(value)
        \(register)=D+\(addend)
        """
    }
    
    private func pushPositiveConstant(_ c: String) {
        append(
        """
        @\(c)
        D=A
        \(pushDToStack())
        """
        )
    }
    
    private func pushNegativeConstant(_ c: String) {
        append(
        """
        @\(c.dropFirst())
        D=-A
        \(pushDToStack())
        """
        )
    }
    
    private func pushDToStack() -> String {
        """
        \(aEqualsSP())
        M=D
        \(incrementSP())
        """
    }
    
    private func bool(_ predicate: String) {
        sub()
        append(
        """
        @\(predicate + "_TRUE")
        D;J\(predicate.prefix(2))
        D=-1
        \(replaceTop())
        @\(predicate + "_FALSE")
        0;JMP
        (\(predicate + "_TRUE"))
        D=0
        \(replaceTop())
        (\(predicate + "_FALSE"))
        """
        )
    }
    
    private func binaryOperation(_ o: String) {
        append(
        """
        \(popStack())
        A=M-1
        D=\(o == "-" ? "M-D" : "D\(o)M")
        \(replaceTop())
        """
        )
    }
    
    private func unaryOperation(_ sign: String) {
        append(
        """
        \(aEqualsSP(offset: "-1"))
        D=\(sign)M
        M=D
        \(replaceTop())
        """
        )
    }
    
    private func aEqualsSP(offset: String = "") -> String {
        """
        @SP
        A=M\(offset)
        """
    }
    
    private func popStack() -> String {
        """
        \(aEqualsSP(offset: "-1"))
        D=M
        \(decrementSP())
        """
    }
    
    private func replaceTop() -> String {
        """
        \(aEqualsSP(offset: "-1"))
        M=D
        """
    }
    
    private func incrementSP() -> String {
        stepSP(sign: "+")
    }
    
    private func decrementSP() -> String {
        stepSP(sign: "-")
    }
    
    private func stepSP(sign: String) -> String {
        """
        @SP
        M=M\(sign)1
        """
    }
    
    private func append(_ a: String) {
        assembly += (assembly.isEmpty ? "" : "\n") + a
    }
}
