class CountConstrainedIntArray {
    
    fileprivate let underlyingArray: [Int]
    
    var count: Int {
        fatalError("Subclasses must implement")
    }
    
    init(_ a: [Int]) {
        self.underlyingArray = a
        validate(count: a.count)
    }
    
    func validate(count: Int) {
        assert(self.count == count,
               "Must have exactly \(count) elements")
        assert(allSatisfy { $0 == 1 || $0 == 0 },
               "Elements must only be 1 or 0" )
    }
}

extension CountConstrainedIntArray: Collection {
    
    func makeIterator() -> IndexingIterator<[Int]> {
        underlyingArray.makeIterator()
    }
    
    subscript(_ i: Int) -> Int {
        underlyingArray[i]
    }
    
    var startIndex: Int {
        0
    }
    
    var endIndex: Int {
        count
    }
    
    func index(after i: Int) -> Int {
        underlyingArray.index(after: i)
    }
}

extension CountConstrainedIntArray: Equatable {
    
    static func == (lhs: CountConstrainedIntArray, rhs: CountConstrainedIntArray) -> Bool {
        lhs.underlyingArray == rhs.underlyingArray
    }
}

extension CountConstrainedIntArray: CustomStringConvertible {
    
    var description: String {
        underlyingArray.description
    }
}

final class IntX2: CountConstrainedIntArray {
    
    override var count: Int { 2 }
}

final class IntX4: CountConstrainedIntArray {
    
    override var count: Int { 4 }
}

final class IntX8: CountConstrainedIntArray {
    
    override var count: Int { 8 }
}

final class IntX16: CountConstrainedIntArray {
    
    override var count: Int { 16 }
}

extension Array where Element == Int {
    
    var x2: IntX2   { IntX2(self) }
    var x4: IntX4   { IntX4(self) }
    var x8: IntX8   { IntX8(self) }
    var x16: IntX16 { IntX16(self) }
}
