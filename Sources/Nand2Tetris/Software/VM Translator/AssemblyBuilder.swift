class AssemblyBuilder {
    private (set) var assembly = ""
    
    func pushConstant(_ c: String) {
        c[0] == "-"
        ? pushNegativeConstant(c)
        : pushPositiveConstant(c)
    }
    
    func pushThis(offset: String) {
        pushMnemonic("THIS", at: offset)
    }
    
    func popThis(offset: String) {
        popToMnemonic("THIS", at: offset)
    }
    
    func pushThat(offset: String) {
        pushMnemonic("THAT", at: offset)
    }
    
    func popThat(offset: String) {
        popToMnemonic("THAT", at: offset)
    }
    
    func pushLocal(offset: String) {
        pushMnemonic("LCL", at: offset)
    }
    
    func popLocal(offset: String) {
        popToMnemonic("LCL", at: offset)
    }
    
    func pushArgument(offset: String) {
        pushMnemonic("ARG", at: offset)
    }
    
    func popArgument(offset: String) {
        popToMnemonic("ARG", at: offset)
    }
    
    func pushStatic(offset: String, identifier: String) {
        pushValue("\(identifier).\(offset)")
    }
    
    func popStatic(offset: String, identifier: String) {
        popTo("\(identifier).\(offset)")
    }
    
    func pushPointer(offset: String) {
        offset == "0"
        ? pushMnemonic("THIS")
        : pushMnemonic("THAT")
    }
    
    func popPointer(offset: String) {
        offset == "0"
        ? popToMnemonic("THIS")
        : popToMnemonic("THAT")
    }
    
    func pushTemp(offset: String) {
        pushValue("5", at: offset)
    }
    
    func popTemp(offset: String) {
        popTo("5", at: offset)
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
    
    func newFunction(name: String, args: Int) {
        label(name)
        (0..<args).forEach { _ in
            pushConstant("0")
        }
    }
    
    func callFunction(name: String, args: Int) {
        
    }
    
    func functionReturn() {
        
    }
    
#warning("label is supposed to be functionName$label")
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
    
    private func popTo(
        _ segment: String,
        at offset: String = "0"
    ) {
        append(
        """
        \(setRegister("D", value: segment, offset: offset))
        @R15
        M=D
        \(popStack())
        @R15
        A=M
        M=D
        """
        )
    }
    
    private func popToMnemonic(
        _ mnemonic: String,
        at offset: String = "0"
    ) {
        append(
        """
        \(setRegister("D", mnemonic: mnemonic, offset: offset))
        @R15
        M=D
        \(popStack())
        @R15
        A=M
        M=D
        """
        )
    }
    
    private func pushValue(
        _ value: String,
        at offset: String = "0"
    ) {
        append(
        """
        \(setRegister("A", value: value, offset: offset))
        D=M
        \(pushDToStack())
        """
        )
    }
    
    private func pushMnemonic(
        _ mnemonic: String,
        at offset: String = "0"
    ) {
        append(
        """
        \(setRegister("A", mnemonic: mnemonic, offset: offset))
        D=M
        \(pushDToStack())
        """
        )
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
