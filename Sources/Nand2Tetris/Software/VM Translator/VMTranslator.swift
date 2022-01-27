private struct VMLine {
    let code: String
    let file: String
    let function: String
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
        var currentFunction = "null"
        func getCurrentFunction(_ line: String) -> String {
            let words = line.components(separatedBy: " ")
            if words[0] == "function" {
                currentFunction = words[1]
            }
            return currentFunction
        }
        
        vm.cleanLines.forEach {
            toAssembly(
                VMLine(code: $0.element,
                       file: file,
                       function: getCurrentFunction($0.element),
                       index: $0.offset)
            )
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
            case "label":
                b.label(label, function: line.function)
                
            case "goto":
                b.goto(label, function: line.function)
                
            case "if-goto":
                b.ifGoto(label, function: line.function)
                
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
            ? b.pushStatic(offset: offset, identifier: line.file)
            : b.popStatic(offset: offset, identifier: line.file)
            
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
            b.newFunction(name: name, args: argCount)
            
        case "call":
            b.callFunction(name: name, args: argCount, index: line.index)
            
        default:
            fatalError("Unrecognised command '\(command)'")
        }
    }
}

private extension String {
    var cleanLines: EnumeratedSequence<[String]> {
            lines.map {
                $0
                    .droppingComments
                    .trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "[ ]{2,}",
                                     with: " ",
                                     options: .regularExpression)
            }.filter { $0 != "" }.enumerated()
    }
}
