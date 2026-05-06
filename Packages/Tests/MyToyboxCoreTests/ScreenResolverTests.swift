import Foundation
import MyToyboxClipScreens
@testable import MyToyboxCore
import Testing

@Suite struct ScreenResolverTests {
    @Test func queryParameter() {
        let url = URL(string: "https://example.com/?screen=dotsSpinnerDemoScreen")!
        let id: Screen? = ScreenResolver.screen(from: url)
        #expect(id == .dotsSpinnerDemoScreen)
    }

    @Test func queryParameterWithOtherParams() {
        let url = URL(string: "https://example.com/?foo=bar&screen=ringSliderScreen&baz=1")!
        let id: Screen? = ScreenResolver.screen(from: url)
        #expect(id == .ringSliderScreen)
    }

    @Test func pathSegment() {
        let url = URL(string: "https://example.com/my-toybox-clip/badgeDemoScreen/")!
        let id: Screen? = ScreenResolver.screen(from: url)
        #expect(id == .badgeDemoScreen)
    }

    @Test func pathSegmentWithoutTrailingSlash() {
        let url = URL(string: "https://example.com/my-toybox-clip/badgeDemoScreen")!
        let id: Screen? = ScreenResolver.screen(from: url)
        #expect(id == .badgeDemoScreen)
    }

    @Test func noMatch() {
        let url = URL(string: "https://example.com/other/path")!
        let id: Screen? = ScreenResolver.screen(from: url)
        #expect(id == nil)
    }
}
