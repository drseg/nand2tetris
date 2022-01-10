class AssemblyCleaner {
    func clean(_ assembly: String) -> String {
        assembly
            .components(separatedBy: "\n")
            .map {
                $0.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: " ", with: "")
                    .droppingComments
            }
            .filter { $0 != "" }
            .joined(separator: "\n")
    }
}

extension String {
    var droppingComments: String {
        components(separatedBy: "//")[0]
    }
}
