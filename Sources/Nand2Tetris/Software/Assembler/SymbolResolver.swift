class SymbolResolver {
    let staticSymbols = {
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
    
    func resolving(_ assembly: String) -> String {
        makeCommandMap(assembly)
        makeSymbolMap(assembly)
        
        return replacingAll(assembly)
    }
    
    func replacingAll(_ assembly: String) -> String {
        allSymbols
            .sorted { $0.key.count > $1.key.count }
            .reduce(assembly)
        {
            $0.replacing([("\n(\($1.key))", ""),
                          ("(\($1.key))\n", ""),
                          ("(\($1.key))", ""),
                          ($1.key, String($1.value))])
        }
    }
    
    func makeCommandMap(_ assembly: String) {
        var instructionAddress = 0
        
        assembly.eachLine {
            if let command = $0.command {
                commands[command] = instructionAddress
            } else {
                instructionAddress += 1
            }
        }
    }
    
    func makeSymbolMap(_ assembly: String) {
        var address = 16
        
        assembly.eachLine {
            if let symbol = $0.symbol, allSymbols[symbol] == nil {
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
        replacements.reduce(self) { result, replacement in
            result.replacingOccurrences(of: replacement.0,
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
        guard let match = firstMatching("[@][^0-9].*")
        else { return nil }
        
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
