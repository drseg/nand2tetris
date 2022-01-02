protocol Keyboard {
    func didPress(_ key: Char)
    func didRelease(_ key: Char)
    var currentKey: String { get }
}

class MockKeyboard: Keyboard {
    var currentKey: String = "0000000000000000"
    
    func didPress(_ key: Char) {
        guard key != "-" else {
            didRelease(key); return
        }
        currentKey = key.asciiValue?.toBinary() ?? 0.toBinary()
    }
    
    func didRelease(_ key: Char) {
        currentKey = 0.toBinary()
    }
}

typealias Screen = RAM

class Memory {
    private let ram16k = FastRAM(16383)
    private let screen: Screen
    private let keyboard: Keyboard
    
    init(keyboard: Keyboard, screen: Screen) {
        self.keyboard = keyboard
        self.screen = screen
    }
    
    @discardableResult
    func callAsFunction(
        _ word: String,
        _ load: Char,
        _ address: String,
        _ clock: Char
    ) -> String {
        let loadMap = deMux4Way(load, address[0], address[1])
        
        let ramAddress = String(address.dropFirst())
        let screenAddress = String(address.dropFirst(2))
        
        let ramOut = ram16k(word,
                            or(loadMap[0],
                               loadMap[1]),
                            ramAddress,
                            clock)
        
        let screenOut = screen(word,
                               loadMap[2],
                               screenAddress,
                               clock)
        
        return mux4Way16(ramOut,
                         ramOut,
                         screenOut,
                         keyboard.currentKey,
                         address[0],
                         address[1])
    }
}
