class VMTranslator {
    struct VMLine {
        let code: String
        let fileName: String
        let index: Int
        
        var words: [String] {
            code.components(separatedBy: " ")
        }
    }
    
    private let b: AssemblyBuilder
    
    init(_ builder: AssemblyBuilder = AssemblyBuilder()) {
        b = builder
    }
    
    func toAssembly(_ vm: String, file: String = #fileID) -> String {
        vm.lines
            .enumerated()
            .forEach { toAssembly(VMLine(code: $0.element,
                                     fileName: file,
                                     index: $0.offset)) }
        return b.assembly
    }
    
    private func toAssembly(_ line: VMLine) {
        switch line.words.count {
        case 1:
            computationToAssembly(line)
            
        case 2:
            branchingToAssebly(line)
            
        case 3:
            memoryAccessToAssembly(line)
            
        default:
            fatalError("Lines can't have \(line.words.count) words")
        }
    }
    
    private func computationToAssembly(_ line: VMLine) {
        switch line.code {
        case "add":
            b.add()
            
        case "sub":
            b.sub()
            
        case "not":
            b.not()
            
        case "neg":
            b.neg()
            
        case "and":
            b.and()
            
        case "or":
            b.or()
            
        case "eq":
            b.eq(String(line.index))
            
        case "gt":
            b.gt(String(line.index))
            
        case "lt":
            b.lt(String(line.index))
            
        default:
            fatalError("Unrecognised computation '\(line.code)'")
        }
    }
    
    private func branchingToAssebly(_ line: VMLine) {
        let words = line.words
        
        let command = words[0]
        let label = words[1]
        
        switch command {
        case "label":
            b.addLabel(label)
            
        case "goto":
            b.goto(label)
            
        case "if-goto":
            b.ifGoto(label)
            
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
            b.pushConstant(offset)
            
        case "temp":
            accessTemp(command, offset: offset)
            
        case "static":
            accessStatic(command,
                         offset: offset,
                         fileName: line.fileName)
            
        case "pointer":
            offset == "0"
            ? accessPointerZero(command)
            : accessPointerOne(command)
            
        case _ where mnemonic(segment) != nil:
            accessMnemonic(command,
                           segment: segment,
                           offset: offset)
            
        default:
            fatalError("Unrecognised memory command '\(command)'")
        }
    }
    
    private func accessStatic(
        _ c: String,
        offset: String,
        fileName: String
    ) {
        segmentWithValue(c)("\(fileName).\(offset)", "0")
    }
    
    private func accessPointerZero(_ c: String) {
        accessMnemonic(c, segment: "this", offset: "0")
    }
    
    private func accessPointerOne(_ c: String) {
        accessMnemonic(c, segment: "that", offset: "0")
    }
    
    private func accessTemp(_ c: String, offset: String) {
        segmentWithValue(c)("5", offset)
    }
    
    private func accessMnemonic(
        _ c: String,
        segment: String,
        offset: String
    ) {
        segmentWithMnemonic(c)(mnemonic(segment)!, offset)
    }
    
    private func segmentWithMnemonic(_ c: String) -> (String, String) -> () {
        c == "push"
            ? b.pushSegmentWithMnemonic
            : b.popSegmentWithMnemonic
    }
    
    private func segmentWithValue(_ c: String) -> (String, String) -> () {
        c == "push"
            ? b.pushSegmentWithValue
            : b.popSegmentWithValue
    }
    
    private func mnemonic(_ segment: String) -> String? {
        switch segment {
        case "local":
            return "LCL"
            
        case "argument":
            return "ARG"
            
        case "this":
            return "THIS"
            
        case "that":
            return "THAT"
            
        default: return nil
        }
    }
}
