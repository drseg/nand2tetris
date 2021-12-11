import XCTest
@testable import Nand2Tetris

class ClockTests: XCTestCase, Clocked {
    var clockUpdates: [Int] = [Int]()
    var clock: Clock!
    
    override func setUp() {
        clock = Clock(self)
    }

    func run(_ newValue: Int) -> ClockedOutput {
        clockUpdates.append(newValue)
        return newValue
    }
    
    func assertClockAlternates() {
        clockUpdates.enumerated().forEach { i, clock in
            XCTAssertEqual(clock, (i + 1) % 2 == 0 ? 0 : 1)
        }
    }

    func testClockCanRun() {
        clock.run(iterations: 1)
        
        XCTAssertEqual(clockUpdates.count, 1)
        XCTAssertEqual(clockUpdates.first, 1)
    }

    func testClockAlternatesBetween1And0() {
        clock.run(iterations: 10)
        
        XCTAssertEqual(clockUpdates.count, 10)
        assertClockAlternates()
    }
    
    func testClockablesOutputEveryUpdate() {
        clock.run(iterations: 10)
        
        XCTAssertEqual(clock.outputs.count, 10)
        XCTAssertEqual(clock.outputs.map { $0 as! Int }, clockUpdates)
    }
    
    func testClockCanAcceptExternalTiming() {
        let cycles = ["0+", "1", "1+", "2", "2+", "3", "3+", "4", "4+", "5"]
        cycles.forEach { clock.run(cycle: $0) }
        assertClockAlternates()
    }
}
