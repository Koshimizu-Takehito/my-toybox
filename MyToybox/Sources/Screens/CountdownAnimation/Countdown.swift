import Foundation

@MainActor
@Observable
final class Countdown {
    private(set) var count: Double = 10

    private(set) var task: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    func restart() async {
        count = 10
        task = Task { [weak self] in
            let interval = 1.0 / 360.0
            let timer = Timer
                .publish(every: interval, on: .main, in: .common)
                .autoconnect()
            for await _ in timer.values {
                guard let self, count > 0 else {
                    break
                }
                count -= interval
            }
        }
    }
}
