import Testing
@testable import MyToyboxCore

@Test func tagHasExpectedCases() async throws {
    let allCases = Tag.allCases
    #expect(allCases.contains(.layout))
    #expect(allCases.contains(.animation))
    #expect(allCases.contains(.metal))
}

