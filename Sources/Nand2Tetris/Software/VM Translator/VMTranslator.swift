class VMTranslator {
    struct VMLine {
        let code: String
        let fileName: String
        let index: Int
        
        var words: [String] {
            code.components(separatedBy: " ")
        }
    }
    
    private let builder: AssemblyBuilder
    
    init(_ builder: AssemblyBuilder = AssemblyBuilder()) {
        self.builder = builder
    }
    
    func toAssembly(_ vm: String, file: String = #fileID) -> String {
        vm.lines
            .enumerated()
            .forEach { toAssembly(VMLine(code: $0.element,
                                     fileName: file,
                                     index: $0.offset)) }
        return builder.assembly
    }
    
    private func toAssembly(_ line: VMLine) {
        switch line.words.count {
        case 1: computationToAssembly(line)
        case 2: branchingToAssebly(line)
        case 3: memoryAccessToAssembly(line)
        default:
            fatalError("Lines can't have \(line.words.count) words")
        }
    }
    
    private func computationToAssembly(_ line: VMLine) {
        switch line.code {
        case "add": builder.add()
        case "sub": builder.sub()
        case "not": builder.not()
        case "neg": builder.neg()
        case "and": builder.and()
        case "or": builder.or()
        case "eq": builder.eq(String(line.index))
        case "gt": builder.gt(String(line.index))
        case "lt": builder.lt(String(line.index))
        default:
            fatalError("Unrecognised computation '\(line.code)'")
        }
    }
    
    private func branchingToAssebly(_ line: VMLine) {
        let words = line.words
        
        let command = words[0]
        let label = words[1]
        
        switch command {
        case "label": builder.addLabel(label)
        case "goto": builder.goto(label)
        case "if-goto": builder.ifGoto(label)
        default:
            fatalError("Unrecognised branching command '\(command)'")
        }
    }
    
    private func memoryAccessToAssembly(_ line: VMLine) {
        let words = line.words
        
        let command = words[0]
        let segment = words[1]
        let offset = words[2]
        
        switch segment {
        case "constant":
            builder.pushConstant(offset)
            
        case "temp":
            accessTemp(command, offset: offset)
            
        case "static":
            accessStatic(command, offset: offset, fileName: line.fileName)
            
        case "pointer" where offset == "0":
            accessPointerZero(command)
            
        case "pointer" where offset == "1":
            accessPointerOne(command)
            
        case _ where mnemonic(segment) != nil:
            accessMnemonic(command, segment: segment, offset: offset)
            
        default:
            fatalError("Unrecognised memory command '\(command)'")
        }
    }
    
    private func accessStatic(_ c: String, offset: String, fileName: String) {
        c == "push"
        ? builder.pushSegmentWithValue("\(fileName).\(offset)", at: "0")
        : builder.popSegmentWithValue(to: "\(fileName).\(offset)", at: "0")
    }
    
    private func accessPointerZero(_ c: String) {
        accessMnemonic(c, segment: "this", offset: "0")
    }
    
    private func accessPointerOne(_ c: String) {
        accessMnemonic(c, segment: "that", offset: "0")
    }
    
    private func accessTemp(_ c: String, offset: String) {
        c == "push"
        ? builder.pushSegmentWithValue("5", at: offset)
        : builder.popSegmentWithValue(to: "5", at: offset)
    }
    
    private func accessMnemonic(_ c: String, segment: String, offset: String) {
        c == "push"
        ? builder.pushSegmentWithMnemonic(mnemonic(segment)!,
                                          at: offset)
        : builder.popSegmentWithMnemonic(to: mnemonic(segment)!,
                                         at: offset)
    }
    
    private func mnemonic(_ segment: String) -> String? {
        switch segment {
        case "local": return "LCL"
        case "argument": return "ARG"
        case "this": return "THIS"
        case "that": return "THAT"
        default: return nil
        }
    }
}
