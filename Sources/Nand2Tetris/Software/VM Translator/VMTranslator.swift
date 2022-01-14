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
                case "eq": result.append((eq()))
                case "gt": result.append((gt()))
                case "lt": result.append((lt()))
                case "not": result.append(not())
                case "neg": result.append(neg())
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
    
    func not() -> String {
        unary("!")
    }
    
    func neg() -> String {
        unary("-")
    }
    
    func unary(_ sign: String) -> String {
        """
        \(aEqualsStackAddress())
        M=\(sign)M
        \(replaceTop("SP"))
        """
    }
    
    func eq() -> String {
        controlFlow("EQ")
    }
    
    func gt() -> String {
        controlFlow("GT")
    }
    
    func lt() -> String {
        controlFlow("LT")
    }
    
    func controlFlow(_ type: String) -> String {
        """
        \(sub())
        @\(type)
        D;J\(type)
        D=-1
        (\(type))
        \(replaceTop("SP"))
        """
    }
    
    func arithmetic(sign: String) -> String {
        """
        \(pop("SP"))
        A=M
        D=D\(sign)M
        \(replaceTop("SP"))
        """
    }
    
    func pop(_ pointer: String) -> String {
        """
        \(aEqualsStackAddress())
        D=M
        \(decrement("SP"))
        """
    }
    
    func aEqualsStackAddress() -> String {
        """
        @SP
        A=M
        """
    }
    
    func replaceTop(_ pointer: String) -> String {
        """
        @\(pointer)
        A=M
        M=D
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
