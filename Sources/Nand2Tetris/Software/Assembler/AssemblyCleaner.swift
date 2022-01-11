class AssemblyCleaner {
    func clean(_ assembly: String) -> String {
        assembly
            .components(separatedBy: "\n")
            .map { $0.removingWhitespaces.droppingComments }
            .filter { $0 != "" }
            .joined(separator: "\n")
    }
}

extension String {
    var removingWhitespaces: String {
        trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "")
    }
    
    var droppingComments: String {
        components(separatedBy: "//")[0]
    }
}
