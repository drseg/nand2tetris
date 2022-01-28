private struct VMLine {
    let code: String
    let file: String
    let function: String
    let index: Int
    
    var words: [String] {
        code.components(separatedBy: " ")
    }
}

struct VMFile {
    let name: String
    let code: String
}

class VMTranslator {
    private let builder: AssemblyBuilder
    private var currentFunction = "null"
    
    init(_ b: AssemblyBuilder = AssemblyBuilder()) {
        self.builder = b
    }
    
    func sysInit() {
        builder.sysInit()
    }
    
    func translate(_ files: [VMFile]) -> String {
        files.forEach(translate)
        return builder.assembly
    }

    func translate(_ vm: String, file: String = #fileID) -> String {
        translate(VMFile(name: file, code: vm))
        return builder.assembly
    }
    
    private func translate(_ file: VMFile) {
        file.code.cleanLines.forEach {
            toAssembly(
                VMLine(code: $0.element,
                       file: file.name,
                       function: getCurrentFunction($0.element),
                       index: $0.offset)
            )
        }
    }

    private func toAssembly(_ line: VMLine) {
        let words = line.words
        
        switch words.count {
        case 1:
            switch words[0] {
            case "add":
                builder.add()
                
            case "sub":
                builder.sub()
                
            case "not":
                builder.not()
                
            case "neg":
                builder.neg()
                
            case "and":
                builder.and()
                
            case "or":
                builder.or()
                
            case "eq":
                builder.eq(String(line.index))
                
            case "gt":
                builder.gt(String(line.index))
                
            case "lt":
                builder.lt(String(line.index))
                
            case "return":
                builder.functionReturn()
                
            default:
                fatalError("Unrecognised computation '\(line.code)'")
            }
            
        case 2:
            let command = words[0]
            let label = words[1]
            
            switch command {
            case "label":
                builder.label(label, function: line.function)
                
            case "goto":
                builder.goto(label, function: line.function)
                
            case "if-goto":
                builder.ifGoto(label, function: line.function)
                
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
            builder.pushConstant(offset)
            
        case "temp":
            isPush
            ? builder.pushTemp(offset: offset)
            : builder.popTemp(offset: offset)
            
        case "static":
            isPush
            ? builder.pushStatic(offset: offset, identifier: line.file)
            : builder.popStatic(offset: offset, identifier: line.file)
            
        case "pointer":
            isPush
            ? builder.pushPointer(offset: offset)
            : builder.popPointer(offset: offset)
            
        case "local":
            isPush
            ? builder.pushLocal(offset: offset)
            : builder.popLocal(offset: offset)
            
        case "argument":
            isPush
            ? builder.pushArgument(offset: offset)
            : builder.popArgument(offset: offset)
            
        case "this":
            isPush
            ? builder.pushThis(offset: offset)
            : builder.popThis(offset: offset)
            
        case "that":
            isPush
            ? builder.pushThat(offset: offset)
            : builder.popThat(offset: offset)
            
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
            builder.newFunction(name: name, args: argCount)
            
        case "call":
            builder.callFunction(name: name, args: argCount, index: line.index)
            
        default:
            fatalError("Unrecognised command '\(command)'")
        }
    }
    
    private func getCurrentFunction(_ line: String) -> String {
        let words = line.components(separatedBy: " ")
        if words[0] == "function" {
            currentFunction = words[1]
        }
        return currentFunction
    }
}

private extension String {
    var cleanLines: EnumeratedSequence<[String]> {
        lines.map {
            $0
                .droppingComments
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "[ ]{2,}", // more than one space
                                      with: " ",
                                      options: .regularExpression)
        }.filter { $0 != "" }.enumerated()
    }
}
