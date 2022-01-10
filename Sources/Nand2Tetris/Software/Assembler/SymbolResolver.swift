class SymbolResolver {
    let staticSymbols: [String: Int] = {
        (0...15).reduce(into: ["SP": 0,
                               "LCL": 1,
                               "ARG": 2,
                               "THIS": 3,
                               "THAT": 4,
                               "SCREEN": 16384,
                               "KBD": 24576]) {
            $0["R\($1!)"] = $1!
        }
    }()
    
    var commands = [String: Int]()
    var symbols = [String: Int]()
    
    var allSymbols: [String: Int] {
        commands + symbols + staticSymbols
    }
    
    func resolve(_ assembly: String) -> String {
        resolveCommands(assembly)
        resolveSymbols(assembly)
        
        return replacingAll(assembly)
    }
    
    func replacingAll(_ assembly: String) -> String {
        allSymbols.reduce(into: assembly) {
            $0 = $0.replacing([("\n(\($1.key))", ""),
                               ("(\($1.key))\n", ""),
                               ("(\($1.key))", ""),
                               ($1.key, String($1.value))])
        }
    }
    
    func resolveCommands(_ assembly: String) {
        var instructionNumber = 0
        
        assembly.eachLine {
            if let command = $0.command {
                commands[command] = instructionNumber
            } else {
                instructionNumber += 1
            }
        }
    }
    
    func resolveSymbols(_ assembly: String) {
        var address = 1024
        
        assembly.eachLine {
            if let symbol = $0.symbol,
               symbols[symbol] == nil,
               staticSymbols[symbol] == nil,
               commands[symbol] == nil
            {
                symbols[symbol] = address
                address += 1
            }
        }
    }
}

extension Dictionary {
    static func +(lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        lhs.merging(rhs, uniquingKeysWith: { a, _ in a })
    }
}

extension String {
    func replacing(_ replacements: [(String, String)]) -> String {
        replacements.reduce(into: self) { result, replacement in
            result = result.replacingOccurrences(of: replacement.0,
                                                 with: replacement.1)
        }
    }
    
    func eachLine(_ forEach: (String) -> ()) {
        lines.forEach(forEach)
    }
    
    var lines: [String] {
        components(separatedBy: "\n")
    }
    
    var symbol: String? {
        guard let match = firstMatching("[@][^0-9].*") else { return nil }
        return String(match.dropFirst())
    }
    
    var command: String? {
        firstMatching("[(][^0-9][^()]*[)]")?.removingBrackets
    }
    
    func firstMatching(_ regex: String) -> String? {
        guard let range = range(of: regex, options: .regularExpression)
        else { return nil }
        
        return String(self[range])
    }
    
    var removingBrackets: String {
        replacingOccurrences(of: "[()]",
                             with: "",
                             options: .regularExpression)
    }
}
