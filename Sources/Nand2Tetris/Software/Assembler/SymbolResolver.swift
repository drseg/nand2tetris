class SymbolResolver {
    var staticSymbols: [String: Int] = {
        var c = ["SP": 0,
                 "LCL": 1,
                 "ARG": 2,
                 "THIS": 3,
                 "THAT": 4,
                 "SCREEN": 16384,
                 "KBD": 24576]
        
        for i in 0...15 {
            c["R\(i)"] = i
        }
        return c
    }()
    
    var commands = [String: Int]()
    var symbols = [String: Int]()
    
    func resolveCommands(_ assembly: String) {
        var lineNumber = 1
        
        assembly.lines.forEach {
            if let pseudoCommandSymbol = $0.pseudoCommandSymbol {
                commands[pseudoCommandSymbol] = lineNumber
            }
            lineNumber += 1
        }
    }
    
    func resolveSymbols(_ assembly: String) {
        var address = 1024
        
        if let match = assembly.firstMatching("[@].*")?.dropFirst() {
            symbols[String(match)] = address
        }
    }
}

extension String {
    var lines: [String] {
        components(separatedBy: "\n")
    }
    
    var pseudoCommandSymbol: String? {
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
