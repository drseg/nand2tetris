struct Clock {
    private let observer: ClockObserver
    
    init(_ observer: ClockObserver) {
        self.observer = observer
    }
    
    func run(iterations: Int) {
        (1...iterations).forEach { i in
            observer.update(i.isMultiple(of: 2) ? 0 : 1)
        }
    }
}

protocol ClockObserver {
    func update(_ newValue: Int)
}
