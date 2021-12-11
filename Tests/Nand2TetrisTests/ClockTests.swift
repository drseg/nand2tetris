import XCTest
@testable import Nand2Tetris

class ClockTests: XCTestCase, ClockObserver {
    var clockUpdates: [Int] = [Int]()

    func update(_ newValue: Int) {
        clockUpdates.append(newValue)
    }

    func testClockCanRun() {
        Clock(self).run(iterations: 1)
        XCTAssertEqual(clockUpdates.count, 1)
        XCTAssertEqual(clockUpdates.first, 1)
    }

    func testClockAlternatesBetween1And0() {
        Clock(self).run(iterations: 10)
        XCTAssertEqual(clockUpdates.count, 10)
        
        clockUpdates.enumerated().forEach { i, clock in
            XCTAssertEqual(clock, (i + 1) % 2 == 0 ? 0 : 1)
        }
    }
}
