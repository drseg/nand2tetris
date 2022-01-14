class VMTranslator {
    func translate(_ vmCode: String) -> String {
        vmCode.lines.reduce(into: [String]()) { result, line in
            let components = line.components(separatedBy: " ")
            let value = components[2]
            
            result += [translatePushConstant(value)]
        }.joined(separator: "\n")
    }
    
    func translatePushConstant(_ c: String) -> String {
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
}
