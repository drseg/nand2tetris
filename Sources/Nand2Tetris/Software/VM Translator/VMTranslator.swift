class VMTranslator {
    func translate(_ vmCode: String) -> String {
        vmCode.lines.reduce(into: [String]()) { result, line in
            let components = line.components(separatedBy: " ")
            
            if components.count == 3 {
                let constant = components[2]
                result.append(pushConstant(constant))
            }
            else {
                switch line {
                case "add": result.append(add())
                case "sub": result.append(sub())
                case "neg": result.append(neg())
                case "eq": result.append((eq()))
                default: break
                }
            }
        }.joined(separator: "\n")
    }
    
    func pushConstant(_ c: String) -> String {
        """
        @\(c)
        D=A
        @SP
        A=M
        M=D
        \(increment("SP"))
        """
    }
    
    func add() -> String {
        arithmetic(sign: "+")
    }
    
    func sub() -> String {
        arithmetic(sign: "-")
    }
    
    func neg() -> String {
        """
        \(aEqualsStackAddress())
        M=!M
        """
    }
    
    func eq() -> String {
        """
        \(arithmetic(sign: "-"))
        @EQ
        D;JEQ
        D=-1
        (EQ)
        """
    }
    
    func arithmetic(sign: String) -> String {
        """
        \(dEqualsTopOfStack())
        \(decrement("SP"))
        A=M
        D=D\(sign)M
        """
    }
    
    func dEqualsTopOfStack() -> String {
        """
        \(aEqualsStackAddress())
        D=M
        """
    }
    
    func aEqualsStackAddress() -> String {
        """
        @SP
        A=M
        """
    }
    
    func increment(_ pointer: String) -> String {
        adjust(pointer, sign: "+")
    }
    
    func decrement(_ pointer: String) -> String {
        adjust(pointer, sign: "-")
    }
    
    func adjust(
        _ pointer: String,
        by amount: String = "1",
        sign: String
    ) -> String {
        """
        @\(pointer)
        M=M\(sign)\(amount)
        """
    }
}
