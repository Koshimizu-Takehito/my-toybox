import SwiftUI

// プラットフォームごとのエイリアス定義
#if os(iOS) || os(tvOS)
public typealias PlatformView = UIView
public typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
public typealias PlatformView = NSView
public typealias PlatformViewRepresentable = NSViewRepresentable
#endif

// MARK: - PlatformAgnosticViewRepresentable

/// このプロトコルを実装すると、iOSでは自動的にUIViewRepresentableに、macOSではNSViewRepresentableに準拠する
public protocol PlatformAgnosticViewRepresentable: PlatformViewRepresentable {
    associatedtype PlatformViewType
    func makePlatformView(context: Context) -> PlatformViewType
    func updatePlatformView(_ platformView: PlatformViewType, context: Context)
}

#if os(iOS) || os(tvOS)
public extension PlatformAgnosticViewRepresentable where UIViewType == PlatformViewType {
    func makeUIView(context: Context) -> UIViewType {
        makePlatformView(context: context)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        updatePlatformView(uiView, context: context)
    }
}
#endif

// macOS向けの拡張（自動準拠）
#if os(macOS)
public extension PlatformAgnosticViewRepresentable where NSViewType == PlatformViewType {
    func makeNSView(context: Context) -> NSViewType {
        makePlatformView(context: context)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        updatePlatformView(nsView, context: context)
    }
}
#endif
