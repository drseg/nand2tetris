class SymbolResolver {
    func resolve(_ assembly: String)  -> [String: Int] {
        assembly
            .lines
            .reduce(into: ([String: Int](), 0)) { result, line in
                result.1 += 1
                if let pseudoCommandSymbol = line.pseudoCommandSymbol {
                    result.0[pseudoCommandSymbol] = result.1
                }
            }.0
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
