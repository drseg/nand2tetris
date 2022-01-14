import Foundation

class Assembler {
    func assemble(_ assembly: String) -> [String] {
        let cleaner = AssemblyCleaner()
        let resolver = SymbolResolver()
        let assembly = resolver.resolve(cleaner.clean(assembly))
        
        return assembly.lines.reduce(into: [String]()) {
            if isAInstruction($1) {
                $0.append(aInstructionCode($1))
            }
            else {
                let computation = padComputation($1)
                $0.append(compCode +
                          aluCode(computation.aluMnemonic) +
                          destCode(computation.destMnemonic) +
                          jumpCode(computation.jumpMnemonic))
            }
        }
    }
        
    func isAInstruction(_ i: String) -> Bool {
        i.first == "@"
    }

    func aInstructionCode(_ mnemonic: String) -> String {
        String(mnemonic.dropFirst()).toBinary()
    }
    
    func padComputation(_ computation: String) -> String {
        var padded = computation
        
        if !padded.contains(";") {
            padded += ";null"
        }
        
        if !padded.contains("=") {
            padded = "null=" + padded
        }
        
        return padded
    }
    
    var compCode: String {
        return "111"
    }
    
    func aluCode(_ mnemonic: String) -> String {
        var code = mnemonic.contains("M") ? "1" : "0"
        
        switch mnemonic {
        case "0": code += "101010"
        case "1": code += "111111"
        case "-1": code += "111010"
        case "D": code += "001100"
        case "A", "M": code += "110000"
        case "!D": code += "001101"
        case "!A", "!M": code += "110001"
        case "-D": code += "001111"
        case "-A", "-M": code += "110011"
        case "D+1": code += "011111"
        case "A+1", "M+1": code += "110111"
        case "D-1": code += "001110"
        case "A-1", "M-1": code += "110010"
        case "D+A", "D+M": code += "000010"
        case "D-A", "D-M": code += "010011"
        case "A-D", "M-D": code += "000111"
        case "D&A", "D&M": code += "000000"
        case "D|A", "D|M": code += "010101"
            
        default: code = "******"
        }
        
        return code
    }
    
    func destCode(_ mnemonic: String) -> String {
        switch mnemonic {
        case "null": return "000"
        case "M": return "001"
        case "D": return "010"
        case "MD": return "011"
        case "A": return "100"
        case "AM": return "101"
        case "AD": return "110"
        case "AMD": return "111"
            
        default: return "***"
        }
    }
    
    func jumpCode(_ mnemonic: String) -> String {
        switch mnemonic {
        case "null": return "000"
        case "JGT": return "001"
        case "JEQ": return "010"
        case "JGE": return "011"
        case "JLT": return "100"
        case "JNE": return "101"
        case "JLE": return "110"
        case "JMP": return "111"
            
        default: return "***"
        }
    }
}

extension String {
    var jumpMnemonic: String {
        components(separatedBy: ";").last!
    }
    
    var destMnemonic: String {
        prefix { $0 != ";" }.components(separatedBy: "=").first!
    }
    
    var aluMnemonic: String {
        prefix { $0 != ";" }.components(separatedBy: "=").last!
    }
}
