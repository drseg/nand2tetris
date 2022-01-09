class SymbolResolver {
    func resolve(_ assembly: String)  -> [String: Int] {
        assembly
            .components(separatedBy: "\n")
            .reduce(into: ([String: Int](), 0)) { result, line in
                result.1 += 1
                if let pseudoCommand = line
                    .droppingComments
                    .pseudoCommand {
                    result.0[pseudoCommand] = result.1
                }
            }.0
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
