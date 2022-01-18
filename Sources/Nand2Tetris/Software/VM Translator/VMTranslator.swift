class VMTranslator {
    struct VMLine {
        let code: String
        let fileName: String
        let index: Int
        
        var words: [String] {
            code.components(separatedBy: " ")
        }
    }
    
    func toAssembly(_ vm: String, file: String = #fileID) -> String {
        vm.lines
            .enumerated()
            .map { translated(VMLine(code: $0.element,
                                     fileName: file,
                                     index: $0.offset)) }
            .joined(separator: "\n")
    }
    
    func translated(_ line: VMLine) -> String {
        switch line.words.count {
        case 1: return computationToAssembly(line)
        case 2: return branchingToAssebly(line)
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
            fatalError("Unrecognised computation '\(line.code)'")
        }
    }
    
    func branchingToAssebly(_ line: VMLine) -> String {
        let words = line.words
        
        let command = words[0]
        let label = words[1]
        
        switch command {
        case "label": return addLabel(label)
        case "goto": return goto(label)
        case "if-goto": return ifGoto(label)
        default:
            fatalError("Unrecognised branching command '\(command)'")
        }
    }
    
    func memoryAccessToAssembly(_ line: VMLine) -> String {
        let words = line.words
        
        let command = words[0]
        let segment = words[1]
        let offset = words[2]
        
        switch command {
        case "push" where segment == "constant":
            return pushConstant(offset)
        case "push":
            return push(segment,
                        at: offset,
                        in: line.fileName)
        case "pop":
            return pop(to: segment,
                       at: offset,
                       in: line.fileName)
        default:
            fatalError("Unrecognised memory command '\(command)'")
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
        \(pushDToStack())
        """
    }
    
    func set(
        _ register: String,
        to segment: String,
        at offset: String,
        in file: String
    ) -> String {
        switch segment {
        case _ where mnemonic(segment) != nil:
            return setRegister(register,
                               mnemonic: mnemonic(segment)!,
                               offset: offset)
        case "pointer" where offset == "0":
            return setRegister(register,
                               mnemonic: mnemonic("this")!)
        case "pointer" where offset == "1":
            return setRegister(register,
                               mnemonic: mnemonic("that")!)
        case "temp":
            return setRegister(register,
                               value: "5",
                               offset: offset)
        case "static":
            return setRegister(register,
                               value: "\(file).\(offset)")
        default:
            fatalError("Unrecognised segment '\(segment)'")
        }
    }
    
    func mnemonic(_ segment: String) -> String? {
        switch segment {
        case "local": return "LCL"
        case "argument": return "ARG"
        case "this": return "THIS"
        case "that": return "THAT"
        default: return nil
        }
    }
    
    func setRegister(
        _ register: String,
        mnemonic: String,
        offset: String = "0"
    ) -> String {
        setWithOffsetAddend(register, mnemonic, offset, "M")
    }
    
    func setRegister(
        _ register: String,
        value: String,
        offset: String = "0"
    ) -> String {
        setWithOffsetAddend(register, value, offset, "A")
    }
    
    func setWithOffsetAddend(
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
    
    func pushConstant(_ c: String) -> String {
        c[0] == "-"
        ? pushNegativeConstant(c)
        : pushPositiveConstant(c)
    }
    
    func pushPositiveConstant(_ c: String) -> String {
        """
        @\(c)
        D=A
        \(pushDToStack())
        """
    }
    
    func pushNegativeConstant(_ c: String) -> String {
        """
        @\(c.dropFirst())
        D=-A
        \(pushDToStack())
        """
    }
    
    func pushDToStack() -> String {
        """
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
    
    func bool(_ predicate: String) -> String {
        """
        \(sub())
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
    }
    
    func add() -> String {
        binaryOperation("+")
    }
    
    func sub() -> String {
        binaryOperation("-")
    }
    
    func and() -> String {
        binaryOperation("&")
    }
    
    func or() -> String {
        binaryOperation("|")
    }
    
    func binaryOperation(_ o: String) -> String {
        """
        \(popStack())
        A=M-1
        D=\(o == "-" ? "M-D" : "D\(o)M")
        \(replaceTop())
        """
    }
    
    func not() -> String {
        unaryOperation("!")
    }
    
    func neg() -> String {
        unaryOperation("-")
    }
    
    func unaryOperation(_ sign: String) -> String {
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
        stepSP(sign: "+")
    }
    
    func decrementSP() -> String {
        stepSP(sign: "-")
    }
    
    func stepSP(sign: String) -> String {
        """
        @SP
        M=M\(sign)1
        """
    }
}
