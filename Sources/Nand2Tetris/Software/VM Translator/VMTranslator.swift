private struct VMLine {
    let code: String
    let fileName: String
    let index: Int
    
    var words: [String] {
        code.components(separatedBy: " ")
    }
}

class VMTranslator {
    private let b: AssemblyBuilder
    
    init(_ b: AssemblyBuilder = AssemblyBuilder()) {
        self.b = b
    }
    
    func toAssembly(_ vm: String, file: String = #fileID) -> String {
        vm.lines.enumerated().forEach {
            toAssembly(VMLine(code: $0.element,
                              fileName: file,
                              index: $0.offset))
        }
        return b.assembly
    }
    
    private func toAssembly(_ line: VMLine) {
        let words = line.words
        
        switch words.count {
        case 1:
            switch words[0] {
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
                
            case "return":
                b.functionReturn()
                
            default:
                fatalError("Unrecognised computation '\(line.code)'")
            }
        case 2:
            let command = words[0]
            let label = words[1]
            
            switch command {
#warning("label is supposed to be functionName$label")
            case "label":
                b.label(label)
                
            case "goto":
                b.goto(label)
                
            case "if-goto":
                b.ifGoto(label)
                
            default:
                fatalError("Unrecognised branching command '\(command)'")
            }
            
        case 3:
            switch words[0] {
            case "push", "pop":
                memoryAccessToAssembly(line)
                
            case "function", "call":
                functionToAssembly(line)
                
            default:
                fatalError("Unrecognised command '\(words[0])")
            }
   
        default:
            fatalError("Lines can't have \(line.words.count) words")
        }
    }
    
    private func memoryAccessToAssembly(_ line: VMLine) {
        let words = line.words
        
        let command = words[0]
        let segment = words[1]
        let offset = words[2]
        
        let isPush = command == "push"
        
        switch segment {
        case "constant":
            b.pushConstant(offset)
            
        case "temp":
            isPush
            ? b.pushTemp(offset: offset)
            : b.popTemp(offset: offset)
            
        case "static":
            isPush
            ? b.pushStatic(offset: offset, identifier: line.fileName)
            : b.popStatic(offset: offset, identifier: line.fileName)
            
        case "pointer":
            isPush
            ? b.pushPointer(offset: offset)
            : b.popPointer(offset: offset)
            
        case "local":
            isPush
            ? b.pushLocal(offset: offset)
            : b.popLocal(offset: offset)
            
        case "argument":
            isPush
            ? b.pushArgument(offset: offset)
            : b.popArgument(offset: offset)
            
        case "this":
            isPush
            ? b.pushThis(offset: offset)
            : b.popThis(offset: offset)
            
        case "that":
            isPush
            ? b.pushThat(offset: offset)
            : b.popThat(offset: offset)
            
        default:
            fatalError("Unrecognised segment '\(segment)'")
        }
    }
    
    private func functionToAssembly(_ line: VMLine) {
        let words = line.words
        
        let command = words[0]
        let name = words[1]
        let argCount = Int(words[2])!
        
        switch command {
        case "function":
            b.newFunction(name: name,
                          args: argCount)
        case "call":
            b.callFunction(name: name,
                           args: argCount)
        default:
            fatalError("Unrecognised command '\(command)'")
        }
        
    }
}
