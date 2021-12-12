typealias ClockedOutput = Stringable

protocol Clocked {
    func run(_ newValue: Int) -> ClockedOutput
}

struct Clock {
    private let observer: Clocked
    private (set) var outputs: [ClockedOutput] = [ClockedOutput]()
    
    init(_ observer: Clocked) {
        self.observer = observer
    }
    
    mutating func run(iterations: Int) {
        iterations.times {
            outputs.append(observer.run($0.isEven))
        }
    }
    
    mutating func run(cycle: String) {
        outputs.append(observer.run(cycle.isTock))
    }
}

private extension Int {
    var isEven: Int {
        isMultiple(of: 2) ? 0 : 1
    }
    
    func times(_ block: (Int) -> ()) {
        (1...self).forEach(block)
    }
}

