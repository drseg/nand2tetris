class SymbolResolver {
    var staticSymbols: [String: Int] = {
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
    
    func resolve(_ assembly: String) -> String {
        resolveCommands(assembly)
        resolveSymbols(assembly)
        
        return replacingSymbols(assembly)
    }
    
    func replacingSymbols(_ assembly: String) -> String {
        commands
            .merging(symbols, uniquingKeysWith: { a, _ in a })
            .reduce(into: assembly) { result, symbol in
                result = result.replacing([("\n(\(symbol.key))", ""),
                                           ("(\(symbol.key))\n", ""),
                                           ("(\(symbol.key))", ""),
                                           (symbol.key, String(symbol.value))])
            }
    }
    
    func resolveCommands(_ assembly: String) {
        var instructionNumber = 1
        
        assembly.eachLine {
            if let command = $0.command {
                commands[command] = instructionNumber
            }
            instructionNumber += 1
        }
    }
    
    func resolveSymbols(_ assembly: String) {
        var address = 1024
        
        assembly.eachLine {
            if let symbol = $0.symbol,
               symbols[symbol] == nil,
               commands[symbol] == nil
            {
                symbols[symbol] = address
                address += 1
            }
        }
    }
}

extension String {
    func replacing(_ replacements: [(String, String)]) -> String {
        var s = self
        replacements.forEach {
            s = s.replacingOccurrences(of: $0.0, with: $0.1)
        }
        
        return s
    }
    
    func eachLine(_ forEach: (String) -> ()) {
        lines.forEach(forEach)
    }
    
    var lines: [String] {
        components(separatedBy: "\n")
    }
    
    var symbol: String? {
        guard let match = firstMatching("[@].*") else { return nil }
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
