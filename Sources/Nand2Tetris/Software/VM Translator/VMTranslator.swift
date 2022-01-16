class VMTranslator {
    func translate(_ vmCode: String) -> String {
        vmCode.lines.reduce(into: ([String](), 0)) { result, line in
            func append(_ flowGenerator: (String) -> (String)) {
                result.0.append(flowGenerator(String(result.1)))
                result.1 += 1
            }
            
            func append(_ assemblyGenerator: () -> (String)) {
                result.0.append(assemblyGenerator())
            }
            
            var isMemoryAccess: Bool {
                components.count == 3
            }
            
            let components = line.components(separatedBy: " ")
            
            if isMemoryAccess {
                let segment = components[2]
                result.0.append(pushConstant(segment))
            }
            else {
                switch line {
                case "add": append(add)
                case "sub": append(sub)
                    
                case "eq": append(eq)
                case "gt": append(gt)
                case "lt": append(lt)
                    
                case "not": append(not)
                case "neg": append(neg)
                case "and": append(and)
                case "or": append(or)
                    
                default: break
                }
            }
        }.0.joined(separator: "\n")
    }
    
    func pushConstant(_ c: String) -> String {
        func saveAndIncrement() -> String {
            """
            \(aEquals("SP"))
            M=D
            \(increment("SP"))
            """
        }
        
        if c[0] != "-" {
            return
                """
                @\(c)
                D=A
                \(saveAndIncrement())
                """
        } else {
            return
                """
                @\(c.dropFirst())
                D=-A
                \(saveAndIncrement())
                """
        }
    }
    
    func add() -> String {
        arithmetic(sign: "+")
    }
    
    func sub() -> String {
        arithmetic(sign: "-")
    }
    
    func and() -> String {
        arithmetic(sign: "&")
    }
    
    func or() -> String {
        arithmetic(sign: "|")
    }
    
    func eq(_ count: String) -> String {
        controlFlow("EQ" + count)
    }
    
    func gt(_ count: String) -> String {
        controlFlow("GT" + count)
    }
    
    func lt(_ count: String) -> String {
        controlFlow("LT" + count)
    }
    
    func controlFlow(_ type: String) -> String {
        """
        \(sub())
        @\(type + "_TRUE")
        D;J\(type.prefix(2))
        D=-1
        \(replaceTop("SP"))
        @\(type + "_FALSE")
        0;JMP
        (\(type + "_TRUE"))
        D=0
        \(replaceTop("SP"))
        (\(type + "_FALSE"))
        """
    }
    
    func arithmetic(sign: String) -> String {
        let dCommand = sign == "-"
        ? "D=M\(sign)D"
        : "D=D\(sign)M"
        
        return """
        \(pop("SP"))
        A=M-1
        \(dCommand)
        \(replaceTop("SP"))
        """
    }
    
    func pop(_ pointer: String) -> String {
        """
        \(aEquals("SP", offset: "-1"))
        D=M
        \(decrement("SP"))
        """
    }
    
    func not() -> String {
        unary("!")
    }
    
    func neg() -> String {
        unary("-")
    }
    
    func unary(_ sign: String) -> String {
        """
        \(aEquals("SP", offset: "-1"))
        D=\(sign)M
        M=D
        \(replaceTop("SP"))
        """
    }
    
    func aEquals(_ pointer: String, offset: String = "") -> String {
        """
        @\(pointer)
        A=M\(offset)
        """
    }
    
    func replaceTop(_ pointer: String) -> String {
        """
        \(aEquals(pointer, offset: "-1"))
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
