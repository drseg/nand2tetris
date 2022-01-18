class VMTranslator {
    struct VMLine {
        let code: String
        let fileName: String
        let index: Int
        
        var words: [String] {
            code.components(separatedBy: " ")
        }
    }
    
    func translateToAssembly(
        _ vm: String,
        fileName: String = #function
    ) -> String {
        vm.lines
            .enumerated()
            .map {
                translated(
                    VMLine(code: $0.element,
                           fileName: fileName,
                           index: $0.offset)
                )
            }
            .joined(separator: "\n")
    }
    
    func translated(_ line: VMLine) -> String {
        switch line.words.count {
        case 1: return computationToAssembly(line)
        case 2: return controlFlowToAssebly(line)
        case 3: return memoryAccessToAssembly(line)
        default:
            fatalError("Lines can't have \(line.words.count) words")
        }
    }
    
    func computationToAssembly(_ line: VMLine) -> String {
        switch line.code {
        case "add": return add()
        case "sub": return sub()
        case "not": return not()
        case "neg": return neg()
        case "and": return and()
        case "or": return or()
        case "eq": return eq(String(line.index))
        case "gt": return gt(String(line.index))
        case "lt": return lt(String(line.index))
            
        default:
            fatalError("'\(line.code)' is not a valid computation")
        }
    }
    
    func controlFlowToAssebly(_ line: VMLine) -> String {
        let words = line.words
        let command = words[0]
        let label = words[1]
        
        switch command {
        case "label": return addLabel(label)
        case "goto": return goto(label)
        case "if-goto": return ifGoto(label)
            
        default:
            fatalError("'\(command)' is not a valid branching command")
        }
    }
    
    func addLabel(_ label: String) -> String {
        """
        (\(label))
        """
    }
    
    func goto(_ label: String) -> String {
        """
        @\(label)
        0;JMP
        """
    }
    
    func ifGoto(_ label: String) -> String {
        """
        \(popStack())
        @\(label)
        D;JEQ
        """
    }
    
    func memoryAccessToAssembly(_ line: VMLine) -> String {
        let words = line.words
        let command = words[0]
        let segment = words[1]
        let offset = words[2]
        
        return command == "push"
        ? segment == "constant"
            ? pushConstant(offset)
        : push(segment, at: offset, in: line.fileName)
        : pop(to: segment, at: offset, in: line.fileName)
    }
    
    func pop(
        to segment: String,
        at offset: String,
        in file: String
    ) -> String {
        """
        \(set("D", to: segment, at: offset, in: file))
        @R15
        M=D
        \(popStack())
        @R15
        A=M
        M=D
        """
    }
    
    func push(
        _ segment: String,
        at offset: String,
        in file: String
    ) -> String {
        """
        \(set("A", to: segment, at: offset, in: file))
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
        at offset: String,
        in file: String
    ) -> String {
        if let mnemonic = mnemonic(for: segment) {
            return setRegister(register,
                               toMnemonic: mnemonic,
                               offset: offset)
        }
        
        if segment == "pointer" {
            let segment = offset == "0" ? "this" : "that"
            return setRegister(register,
                               toMnemonic: mnemonic(for: segment)!)
        }
        
        if segment == "temp" {
            return setRegister(register,
                               toValue: "5",
                               offset: offset)
        }
        
        if segment == "static" {
            return setRegister(register,
                               toValue: "\(file).\(offset)")
        }
        
        fatalError("Unrecognised segment '\(segment)'")
    }
    
    func setRegister(
        _ register: String,
        toMnemonic mnemonic: String,
        offset: String = "0"
    ) -> String {
        setWithOffsetRegister(register,
                              to: mnemonic,
                              at: offset,
                              offsetRegister: "M")
    }
    
    func setRegister(
        _ register: String,
        toValue value: String,
        offset: String = "0"
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
