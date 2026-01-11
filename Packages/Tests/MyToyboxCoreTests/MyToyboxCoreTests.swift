import MyToyboxCore
import Testing

@Test func tagHasExpectedCases() throws {
    let allCases = Tag.allCases
    #expect(allCases.contains(.layout))
    #expect(allCases.contains(.animation))
    #expect(allCases.contains(.metal))
}
