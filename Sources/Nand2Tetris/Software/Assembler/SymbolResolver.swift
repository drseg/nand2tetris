class SymbolResolver {
    func resolve(_ assembly: String)  -> [String: Int] {
        var lineNumber = 0
        
        return assembly
            .components(separatedBy: "\n")
            .reduce(into: [String: Int]()) { result, line in
                lineNumber += 1
                if let pseudoCommand = line
                    .droppingComments
                    .pseudoCommand {
                    result[pseudoCommand] = lineNumber
                }
            }
    }
}

extension String {
    var droppingComments: String {
        components(separatedBy: "//")[0]
    }
    
    var pseudoCommand: String? {
        guard let range = range(of: "[(][^0-9][^()]*[)]",
                                options: .regularExpression) else {
            return nil
        }
        
        return String(self[range].dropFirst().dropLast())
    }
}
