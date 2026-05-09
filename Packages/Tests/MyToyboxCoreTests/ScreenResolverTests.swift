import Foundation
@testable import MyToyboxCore
import MyToyboxScreens
import Testing

@Suite struct ScreenResolverTests {
    @Test func queryParameter() {
        let url = URL(string: "https://example.com/?screen=dotsSpinnerDemoScreen")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == .dotsSpinnerDemoScreen)
    }

    @Test func queryParameterWithOtherParams() {
        let url = URL(string: "https://example.com/?foo=bar&screen=ringSliderScreen&baz=1")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == .ringSliderScreen)
    }

    @Test func pathSegment() {
        let url = URL(string: "https://example.com/my-toybox-clip/badgeDemoScreen/")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == .badgeDemoScreen)
    }

    @Test func pathSegmentWithoutTrailingSlash() {
        let url = URL(string: "https://example.com/my-toybox-clip/badgeDemoScreen")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == .badgeDemoScreen)
    }

    @Test func firebaseDomainPath() {
        let url = URL(string: "https://my-toybox.web.app/my-toybox-clip/badgeDemoScreen/")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == .badgeDemoScreen)
    }

    @Test func firebaseDomainQuery() {
        let url = URL(string: "https://my-toybox.web.app/?screen=badgeDemoScreen")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == .badgeDemoScreen)
    }

    @Test func noMatch() {
        let url = URL(string: "https://example.com/other/path")!
        let id: AppScreen? = ScreenResolver.screen(from: url)
        #expect(id == nil)
    }
}
