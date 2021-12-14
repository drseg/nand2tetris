class CountConstrainedIntArray {
    
    let underlyingArray: [Int]
    
    var count: Int {
        fatalError("Subclasses must implement")
    }
    
    init(_ a: [Int]) {
        underlyingArray = a
        validate(count: a.count)
    }
    
    private func validate(count: Int) {
        assert(self.count == count,
               "Must have exactly \(self.count) elements")
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

final class IntX3: CountConstrainedIntArray {
    
    override var count: Int { 3 }
}

final class IntX4: CountConstrainedIntArray {
    
    override var count: Int { 4 }
}

final class IntX6: CountConstrainedIntArray {
    
    override var count: Int { 6 }
}

final class IntX8: CountConstrainedIntArray {
    
    override var count: Int { 8 }
}

final class IntX9: CountConstrainedIntArray {
    
    override var count: Int { 9 }
}

final class IntX12: CountConstrainedIntArray {
    
    override var count: Int { 12 }
}

final class IntX14: CountConstrainedIntArray {
    
    override var count: Int { 14 }
}

final class IntX16: CountConstrainedIntArray {
    
    override var count: Int { 16 }
}

extension Array where Element == Int {
    
    var x2: IntX2   { IntX2(self) }
    var x3: IntX3   { IntX3(self) }
    var x4: IntX4   { IntX4(self) }
    var x6: IntX6   { IntX6(self) }
    var x8: IntX8   { IntX8(self) }
    var x9: IntX9   { IntX9(self) }
    var x12: IntX12 { IntX12(self) }
    var x14: IntX14 { IntX14(self) }
    var x16: IntX16 { IntX16(self) }
}

extension StringProtocol {
    
    var int: Int    { Int(String(self))! }
    var x2: IntX2   { xX.x2 }
    var x3: IntX3   { xX.x3 }
    var x4: IntX4   { xX.x4 }
    var x6: IntX6   { xX.x6 }
    var x8: IntX8   { xX.x8 }
    var x9: IntX9   { xX.x9 }
    var x12: IntX12 { xX.x12 }
    var x14: IntX14 { xX.x14 }
    var x16: IntX16 { xX.x16 }
    
    var xX: [Int] { map(String.init).compactMap(Int.init) }
}

protocol Stringable {
    var toString: String { get }
}

extension Int: Stringable {
    var toString: String { String(self) }
}

extension String: Stringable {
    var toString: String { self }
}

extension CountConstrainedIntArray: Stringable {
    var toString: String { map(String.init).joined() }
}



