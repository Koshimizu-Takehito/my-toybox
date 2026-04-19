import MyToyboxCore
import Testing

@Suite struct TagTests {
    @Test func hasExpectedCases() throws {
        let allCases = Tag.allCases
        #expect(allCases.contains(.layout))
        #expect(allCases.contains(.animation))
        #expect(allCases.contains(.metal))
    }
}
