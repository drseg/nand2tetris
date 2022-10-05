class SymbolResolver {
    func resolve(_ assembly: String) -> String {
        replaceSymbols(findCommands(assembly) +
                       findSymbols(assembly) +
                       staticSymbols,
                       in: assembly)
    }
    
    private func findCommands(_ assembly: String) -> [String: Int] {
        var instructionAddress = 0
        var commands = [String: Int]()
        
        assembly.eachLine {
            if let command = $0.command {
                commands[command] = instructionAddress
            } else {
                instructionAddress += 1
            }
        }
        
        return commands
    }
    
    private func findSymbols(_ assembly: String) -> [String: Int] {
        var address = 16
        var symbols = staticSymbols
        
        assembly.eachLine {
            if let symbol = $0.symbol, symbols[symbol] == nil {
                symbols[symbol] = address
                address += 1
            }
        }
        
        return symbols
    }
    
    private lazy var staticSymbols = {
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
    
    private func replaceSymbols(_ symbols: [String: Int], in assembly: String) -> String {
        symbols
            .sorted { $0.key.count > $1.key.count }
            .reduce(assembly)
        {
            $0.replacing([("\n(\($1.key))", ""),
                          ("(\($1.key))\n", ""),
                          ("(\($1.key))", ""),
                          ($1.key, String($1.value))])
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
        components(separatedBy: "\n").filter { !$0.isEmpty }
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
