import XCTest
@testable import Nand2Tetris

class Memorytests: XCTestCase {
    func testAcceptance() throws {
        let keyboard = MockKeyboard()
        let memory = Memory(keyboard: keyboard,
                            screen: FastRAM(8192))
        
        try FileBasedATR("Computer/Memory") {
            let clock = $0[0].clockSignal
            let word = $0[2].toBinary()
            let load = $0[3].toChar
            let address = $0[4]
            
            keyboard.didPress($0[1].toChar)
            
            return [memory(word,
                           load,
                           address,
                           clock).toDecimal()]
            
        }.run()
    }
}
