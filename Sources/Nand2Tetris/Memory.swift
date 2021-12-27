class Memory {
    private let ram16ks = [FastRAM](count: 2, forEach: FastRAM(16384))
    
    func callAsFunction(_ word: String, _ load: Char, _ address: String, _ clock: Char) -> String {
        let loadMap = deMux(load, address[0])
        let clockMap = deMux(clock, address[0])
        
        let ram16KAddress = String(address.suffix(14))
        
        let out = ram16ks.enumerated().reduce(into: [String]()) {
            $0.append(
                $1.element(word,
                           loadMap[$1.offset],
                           ram16KAddress,
                           clockMap[$1.offset])
            )
        }
        
        return mux16(out[0], out[1], address[0])
    }
}
