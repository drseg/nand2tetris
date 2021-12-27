class Memory {
    private let ram16k = FastRAM(16384)
    private let screen: Screen
    private let keyboard: Keyboard
    
    init(keyboard: Keyboard, screen: Screen) {
        self.keyboard = keyboard
        self.screen = screen
    }
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        let loadMap = deMux4Way(load, address[0], address[1])
        let clockMap = deMux4Way(clock, address[0], address[1])
        
        let ramAddress = address.suffix(address.count - 1)
        let screenAddress = address.suffix(address.count - 2)
        
        let ramOut = ram16k(word,
                            or(loadMap[0], loadMap[1]),
                            String(ramAddress),
                            or(clockMap[0], clockMap[1]))
        
        let screenOut = screen(word,
                               loadMap[2],
                               String(screenAddress),
                               clockMap[2])

        return mux4Way16(ramOut,
                  ramOut,
                  screenOut,
                  keyboard.currentKey,
                  address[0],
                  address[1])
    }
}

protocol Keyboard {
    func didPress(_ key: Char)
    func didRelease(_ key: Char)
    var currentKey: String { get }
}

class MockKeyboard: Keyboard {
    var currentKey: String = "0000000000000000"
    
    func didPress(_ key: Char) {
        guard key != "-" else {
            didRelease(key)
            return
        }
        currentKey = key.asciiValue?.toBinary() ?? 0.toBinary()
    }
    
    func didRelease(_ key: Char) {
        currentKey = 0.toBinary()
    }
}

protocol Screen: RAM { }

class MockScreen: Screen {
    private let ram = FastRAM(8192)
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        ram(word, load, address, clock)
    }
}
