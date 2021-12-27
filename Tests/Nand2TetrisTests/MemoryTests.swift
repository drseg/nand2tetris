import XCTest
@testable import Nand2Tetris

class Memorytests: XCTestCase {
    
    func testAcceptance() throws {
        let keyboard = MockKeyboard()
        let screen = FastRAM(8192)
        let memory = Memory(keyboard: keyboard,
                            screen: screen)
        
        try FileBasedATR("Computer/Memory") {
            let clock = $0[0].clockSignal
            let key = $0[1].toChar
            let word = $0[2].toBinary()
            let load = $0[3].toChar
            let address = $0[4]
            
            keyboard.didPress(key)
            
            return [memory(word,
                           load,
                           address,
                           clock).toDecimal()]
            
        }.run()
    }
}
