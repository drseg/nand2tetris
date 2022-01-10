class AssemblyCleaner {
    func clean(_ assembly: String) -> String {
        assembly
            .components(separatedBy: "\n")
            .map { $0.droppingComments.trimmingCharacters(in: .whitespaces) }
            .filter { $0 != "" }
            .joined(separator: "\n")
    }
}

extension String {
    var droppingComments: String {
        components(separatedBy: "//")[0]
    }
}
