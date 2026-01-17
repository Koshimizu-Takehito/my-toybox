import SwiftUI

// MARK: - DateformatStyleScreen

/// A screen that demonstrates how a date is formatted using
/// different combinations of calendar, locale, and time zone,
/// via `Date.FormatStyle`.
@Metadata(title: "Dateformat Style", description: "Date.FormatStyle の出力サンプル", tags: [])
struct DateformatStyleScreen: View {
    /// A sample date to be formatted and displayed.
    @State private var sampleDate = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00+09:00")!
    /// The currently selected locale (language).
    @State private var selectedLanguage: LanguageCode = .japanese
    /// The currently selected time zone.
    @State private var selectedTimeZone: TimeZoneID = .jst
    /// The currently selected calendar.
    @State private var selectedCalendar: CalendarName = .gregorian

    var body: some View {
        NavigationStack {
            List {
                // Output preview
                Section("出力") {
                    DateCell($sampleDate, style: fullStyle)
                    DateCell($sampleDate, style: compactStyle)
                }

                // Calendar selection
                Section("暦法") {
                    ForEach(CalendarName.allCases, id: \.self) {
                        SelectionCell($selectedCalendar, value: $0)
                    }
                }

                // Locale (language) selection
                Section("ロケール") {
                    ForEach(LanguageCode.allCases, id: \.self) {
                        SelectionCell($selectedLanguage, value: $0)
                    }
                }

                // Time zone selection
                Section("タイムゾーン") {
                    ForEach(TimeZoneID.allCases, id: \.self) {
                        SelectionCell($selectedTimeZone, value: $0)
                    }
                }
            }
            // Apply selected values into the environment
            .environment(\.locale, Locale(identifier: selectedLanguage.rawValue))
            .environment(\.timeZone, TimeZone(selectedTimeZone))
            .environment(\.calendar, Calendar(identifier: selectedCalendar.identifier))
            .animation(.default, value: sampleDate)
            .animation(.default, value: selectedLanguage)
            .animation(.default, value: selectedTimeZone)
            .animation(.default, value: selectedCalendar)
            .tint(.orange)
            .navigationTitle("Date Format Style")
        }
    }

    /// A verbose date and time format.
    private var fullStyle: Date.FormatStyle {
        .dateTime.year().month().day().hour().minute().second()
    }

    /// A compact style using two-digit month/day.
    private var compactStyle: Date.FormatStyle {
        .dateTime.year().month(.twoDigits).day(.twoDigits)
    }
}

// MARK: - DateCell

/// A reusable cell that displays the formatted date using the injected style
private struct DateCell: View {
    @Binding private var date: Date
    @EnvironmentFormat private var style: Date.FormatStyle

    init(_ date: Binding<Date>, style: Date.FormatStyle) {
        self._date = date
        self._style = .init(wrappedValue: style)
    }

    var body: some View {
        Text(date.formatted(style))
            .font(.body.monospacedDigit().bold())
    }
}

// MARK: - EnvironmentFormat

/// A property wrapper that applies the current environment's calendar, time zone,
/// and locale to the given `Date.FormatStyle`.
@propertyWrapper
private struct EnvironmentFormat: DynamicProperty {
    @Environment(\.locale) private var locale
    @Environment(\.timeZone) private var timeZone
    @Environment(\.calendar) private var calendar

    private var value: Date.FormatStyle

    init(wrappedValue value: Date.FormatStyle) {
        self.value = value
    }

    var wrappedValue: Date.FormatStyle {
        var updated = value
        updated.timeZone = timeZone
        updated.locale = locale
        updated.calendar = calendar
        return updated
    }
}

// MARK: - SelectionCell

/// A reusable selection row with a checkmark to indicate the current value
private struct SelectionCell<T: Equatable>: View {
    @Binding private var selection: T
    private let value: T

    init(_ selection: Binding<T>, value: T) {
        _selection = selection
        self.value = value
    }

    var body: some View {
        Button {
            selection = value
        } label: {
            HStack {
                Text(String(describing: value))
                Spacer()
                Image(systemName: "checkmark")
                    .opacity(selection == value ? 1 : 0)
            }
        }
    }
}

// MARK: - LanguageCode

/// Supported language identifiers (locale codes)
private enum LanguageCode: String, Hashable, CaseIterable, CustomStringConvertible {
    case japanese = "ja_JP"
    case english = "en_US"
    case thai = "th_TH"
    case hindi = "hi_IN"

    var description: String { rawValue }
}

// MARK: - TimeZoneID

/// Supported time zone identifiers
private enum TimeZoneID: String, Hashable, CaseIterable, CustomStringConvertible {
    case jst = "JST"
    case utc = "UTC"

    var description: String { rawValue }
}

// MARK: - CalendarName

/// Supported calendar identifiers with localized descriptions
private enum CalendarName: String, Hashable, CaseIterable, CustomStringConvertible {
    case gregorian = "グレゴリオ暦"
    case japanese = "和暦"
    case chinese = "中国暦"
    case buddhist = "仏暦"
    case indian = "インド暦"

    var identifier: Calendar.Identifier {
        switch self {
        case .gregorian:
            .gregorian

        case .japanese:
            .japanese

        case .chinese:
            .chinese

        case .buddhist:
            .buddhist

        case .indian:
            .indian
        }
    }

    var description: String { rawValue }
}

// MARK: - TimeZone init extension

private extension TimeZone {
    init(_ id: TimeZoneID) {
        self.init(identifier: id.rawValue)!
    }
}

// MARK: - Preview

#Preview {
    DateformatStyleScreen()
}
