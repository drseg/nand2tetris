class VMTranslator {
    func translate(_ vmCode: String) -> String {
        vmCode
            .lines
            .enumerated()
            .map(translateLine)
            .joined(separator: "\n")
    }
    
    func translateLine(_ line: (i: Int, vmCode: String)) -> String {
        let words = line.vmCode.components(separatedBy: " ")
        
        switch words.count {
        case 1:
            switch line.1 {
            case "add": return add()
            case "sub": return sub()
            case "not": return not()
            case "neg": return neg()
            case "and": return and()
            case "or": return or()
            case "eq": return eq(String(line.i))
            case "gt": return gt(String(line.i))
            case "lt": return lt(String(line.i))
                
            default:
                fatalError(
                    "'\(line.1)' is not a valid command"
                )
            }
        case 3:
            let command = words[0]
            let segment = words[1]
            let offset = words[2]
            
            return command == "push"
            ? segment == "constant"
                ? pushConstant(offset)
                : push(segment, at: offset)
            : pop(to: segment, at: offset)
            
        default:
            fatalError(
                "VM lines can't have \(words.count) words"
            )
        }
    }
    
    func pop(to segment: String, at offset: String) -> String {
        """
        \(set("D", to: segment, at: offset))
        @R15
        M=D
        \(popStack())
        @R15
        A=M
        M=D
        """
    }
    
    func push(_ segment: String, at offset: String) -> String {
        """
        \(set("A", to: segment, at: offset))
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        """
    }
    
    func set(
        _ register: String,
        to segment: String,
        at offset: String
    ) -> String {
        if let mnemonic = mnemonic(for: segment) {
            return setRegister(register,
                               toMnemonic: mnemonic,
                               at: offset)
        }
        
        if segment == "pointer" {
            let segment = offset == "0" ? "this" : "that"
            return setRegister(register,
                               toMnemonic: mnemonic(for: segment)!,
                               at: "0")
        }
        
        if segment == "temp" {
            return setRegister(register,
                               toValue: "5",
                               at: offset)
        }
        
        fatalError("Unrecognised segment '\(segment)'")
    }
    
    func setRegister(
        _ register: String,
        toMnemonic mnemonic: String,
        at offset: String
    ) -> String {
        setWithOffsetRegister(register,
                              to: mnemonic,
                              at: offset,
                              offsetRegister: "M")
    }
    
    func setRegister(
        _ register: String,
        toValue value: String,
        at offset: String
    ) -> String {
        setWithOffsetRegister(register,
                              to: value,
                              at: offset,
                              offsetRegister: "A")
    }
    
    func setWithOffsetRegister(
        _ register: String,
        to value: String,
        at offset: String,
        offsetRegister: String
    ) -> String {
        """
        @\(offset)
        D=A
        @\(value)
        \(register)=D+\(offsetRegister)
        """
    }
    
    func mnemonic(for segment: String) -> String? {
        switch segment {
        case "local": return "LCL"
        case "argument": return "ARG"
        case "this": return "THIS"
        case "that": return "THAT"
            
        default: return nil
        }
    }
    
    func pushConstant(_ c: String) -> String {
        let isNeg = c[0] == "-"
        
        return """
        @\(isNeg ? String(c.dropFirst()) : c)
        D=\(isNeg ? "-A" : "A")
        \(aEqualsSP())
        M=D
        \(incrementSP())
        """
    }
    
    func eq(_ count: String) -> String {
        bool("EQ" + count)
    }
    
    func gt(_ count: String) -> String {
        bool("GT" + count)
    }
    
    func lt(_ count: String) -> String {
        bool("LT" + count)
    }
    
    func bool(_ condition: String) -> String {
        """
        \(sub())
        @\(condition + "_TRUE")
        D;J\(condition.prefix(2))
        D=-1
        \(replaceTop())
        @\(condition + "_FALSE")
        0;JMP
        (\(condition + "_TRUE"))
        D=0
        \(replaceTop())
        (\(condition + "_FALSE"))
        """
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
    
    func arithmetic(sign: String) -> String {
        let dCommand = sign == "-"
        ? "D=M\(sign)D"
        : "D=D\(sign)M"
        
        return """
        \(popStack())
        A=M-1
        \(dCommand)
        \(replaceTop())
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
        \(aEqualsSP(offset: "-1"))
        D=\(sign)M
        M=D
        \(replaceTop())
        """
    }
    
    func aEqualsSP(offset: String = "") -> String {
        """
        @SP
        A=M\(offset)
        """
    }
    
    func popStack() -> String {
        """
        \(aEqualsSP(offset: "-1"))
        D=M
        \(decrementSP())
        """
    }
    
    func replaceTop() -> String {
        """
        \(aEqualsSP(offset: "-1"))
        M=D
        """
    }
    
    func incrementSP() -> String {
        adjustSP(sign: "+")
    }
    
    func decrementSP() -> String {
        adjustSP(sign: "-")
    }
    
    func adjustSP(sign: String) -> String {
        """
        @SP
        M=M\(sign)1
        """
    }
}
