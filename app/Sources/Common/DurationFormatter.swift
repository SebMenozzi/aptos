import Foundation

private extension Collection where Element == Calendar.Component {
    
    var matchingUnits: NSCalendar.Unit {
        var units: NSCalendar.Unit = []

        for component in self {
            switch component {
            case .year:
                units.insert(.year)
            case .month:
                units.insert(.month)
            case .day:
                units.insert(.day)
            case .hour:
                units.insert(.hour)
            case .minute:
                units.insert(.minute)
            case .second:
                units.insert(.second)
            default:
                break
            }
        }

        return units
    }
}

public final class DurationFormatter {

    private init() { }

    /**
     Formats a duration in a short length, at least one component and up-to-two components format
     like "2 hr, 42min" or "2 hr". A single component is displayed when the second one is zero.
     Formatting is done using the current system locale.

     - parameters:
        - ti: The time interval, measured in seconds. The value must be a finite number.
     Negative numbers are treated as positive numbers when creating the string.

     - returns:
     A formatted duration a "2 hr, 42min" or "2 hr" format
     */
    public static func stringShort(from ti: TimeInterval) -> String {
        return stringShort(locale: nil, from: computeComponents(from: ti))
    }


    /**
     Formats a duration in a short length, at least one component and up-to-two components format
     like "2 hr, 42min" or "2 hr". A single component is displayed when the second one is zero.
     Formatting is done using the current system locale.

     - parameters:
     - ti: The time interval, measured in seconds. The value must be a finite number.
     Negative numbers are treated as positive numbers when creating the string.
     - allowedComponents: The components allowed in the returned string.

     - returns:
     A formatted duration a "2 hr, 42min" or "2 hr" format containing only specified components
     */
    public static func stringShort(from ti: TimeInterval, allowedComponents: Set<Calendar.Component>) -> String {
        return stringShort(locale: nil, from: computeComponents(from: ti), allowedComponents: allowedComponents)
    }

    /**
     Formats a duration in a short length, at least one component and up-to-two components format
     like "2 hr, 42min" or "2 hr". A single component is displayed when the second one is zero.
     Formatting is done using the current system locale.

     - parameters:
       - components: A date com components object containing the date and time information
     to format. Note that only the days, hours, minutes are taken into account to actually
     generate the string. All other components are ignored. This parameter must not be nil.

     - returns:
     A formatted duration a "2 hr, 42min" or "2 hr" format
     */
    public static func stringShort(from components: DateComponents) -> String {
        return stringShort(locale: nil, from: components)
    }

    // Visible for testing
    internal static func stringShort(locale: Locale?, from components: DateComponents) -> String {
        return string(
            locale: locale,
            from: components,
            unitsStyle: .short,
            maximumUnitCount: 2
        )
    }


    // Visible for testing
    internal static func stringShort(locale: Locale?, from components: DateComponents, allowedComponents: Set<Calendar.Component>) -> String {
        return string(
            locale: locale,
            from: components,
            unitsStyle: .short,
            maximumUnitCount: allowedComponents.count,
            allowedUnits: allowedComponents.matchingUnits)
    }

    /**
     Formats a duration in a short  length, exactly one component format like "2 hr" or "1min".
     Formatting is done using the current system locale.

     - parameters:
        - ti: The time interval, measured in seconds. The value must be a finite number.
     Negative numbers are treated as positive numbers when creating the string.

     - returns:
     A formatted duration in a "2 hr" or "1min" format
     */
    public static func stringShortOneUnit(from ti: TimeInterval, allowedComponents: Set<Calendar.Component> = [.day, .hour, .minute, .second]) -> String {
        return stringShortOneUnit(locale: nil, from: computeComponents(from: ti, allowedComponents: allowedComponents))
    }

    /**
     Formats a duration in a short length, exactly one component format like "2 hr" or "1min".
     Formatting is done using the current system locale.

     - parameters:
        - components: A date com components object containing the date and time information
     to format. Note that only the days, hours, minutes are taken into account to actually
     generate the string. All other components are ignored. This parameter must not be nil.

     - returns:
     A formatted duration in a "2 hr" or "1min" format
     */
    public static func stringShortOneUnit(from components: DateComponents) -> String {
        return stringShortOneUnit(locale: nil, from: components)
    }

    // Visible for testing
    internal static func stringShortOneUnit(locale: Locale?, from components: DateComponents) -> String {
        return string(
            locale: locale,
            from: components,
            unitsStyle: .short,
            maximumUnitCount: 1
        )
    }

    /**
     Formats a duration in a narrow length, at least one component and up-to-two components format
     like "2h 42m" or "2h". A single component is displayed when the second one is zero.
     Formatting is done using the current system locale.

     - parameters:
        - ti: The time interval, measured in seconds. The value must be a finite number.
     Negative numbers are treated as positive numbers when creating the string.

     - returns:
     A formatted duration in a "2h 42m" or "2h" format
     */
    public static func stringNarrow(from ti: TimeInterval, allowedComponents: Set<Calendar.Component> = [.day, .hour, .minute, .second]) -> String {
        return stringNarrow(locale: nil, from: computeComponents(from: ti, allowedComponents: allowedComponents))
    }

    /**
     Formats a duration in a narrow length, at least one component and up-to-two components format
     like "2h 42m" or "2h". A single component is displayed when the second one is zero.
     Formatting is done using the current system locale.

     - parameters:
        - components: A date com components object containing the date and time information
     to format. Note that only the days, hours, minutes are taken into account to actually
     generate the string. All other components are ignored. This parameter must not be nil.

     - returns:
     A formatted duration in a "2h 42m" or "2h" format
     */
    public static func stringNarrow(from components: DateComponents) -> String {
        return stringNarrow(locale: nil, from: components)
    }

    // Visible for testing
    internal static func stringNarrow(locale: Locale?, from components: DateComponents) -> String {
        return string(
            locale: locale,
            from: components,
            unitsStyle: .abbreviated,
            maximumUnitCount: 2
        )
    }

    /**
     Formats a duration in a long length, exactly one component format like "2 hours" or "1 minute".
     Formatting is done using the current system locale.

     - parameters:
        - ti: The time interval, measured in seconds. The value must be a finite number.
     Negative numbers are treated as positive numbers when creating the string.

     - returns:
     A formatted duration in a "2 hours" or "1 minute" format
     */
    public static func stringLongOneUnit(from ti: TimeInterval) -> String {
        return stringLongOneUnit(locale: nil, from: computeComponents(from: ti))
    }

    /**
     Formats a duration in a long length, exactly one component format like "2 hours" or "1 minute".
     Formatting is done using the current system locale.

     - parameters:
        - components: A date com components object containing the date and time information
     to format. Note that only the days, hours, minutes are taken into account to actually
     generate the string. All other components are ignored. This parameter must not be nil.

     - returns:
     A formatted duration in a "2 hours" or "1 minute" format
     */
    public static func stringLongOneUnit(from components: DateComponents) -> String {
        return stringLongOneUnit(locale: nil, from: components)
    }

    // Visible for testing
    internal static func stringLongOneUnit(locale: Locale?, from components: DateComponents) -> String {
        return string(
            locale: locale,
            from: components,
            unitsStyle: .full,
            maximumUnitCount: 1
        )
    }

    /**
     Formats a duration in a hour/minute/second format "2:12:34" or "0:00:12".
     Formatting is done using the current system locale.

     - parameters:
        - ti: The time interval, measured in seconds. The value must be a finite number.
     Negative numbers are treated as positive numbers when creating the string.
        - allowedUnits: The calendar units allowed in the returned string.

     - returns:
     A formatted duration in a "2:12:34" or "0:00:12" format
     */
    public static func stringPositional(from ti: TimeInterval, allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]) -> String {
        return stringPositional(from: computeComponents(from: ti), allowedUnits: allowedUnits)
    }

    /**
     Formats a duration in a hour/minute/second format "2:12:34" or "0:00:12".
     Formatting is done using the current system locale.

     - parameters:
        - components: A date com components object containing the date and time information
     to format. Note that only the days, hours, minutes are taken into account to actually
     generate the string. All other components are ignored. This parameter must not be nil.
        - allowedallowedUnits: The calendar units allowed in the returned string.


     - returns:
     A formatted duration in a "2:12:34" or "0:00:12" format
     */
    public static func stringPositional(from components: DateComponents, allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]) -> String {
        return stringPositional(locale: nil, from: components, allowedUnits: allowedUnits)
    }

    // Visible for testing
    internal static func stringPositional(locale: Locale?, from components: DateComponents, allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]) -> String {
        let formatter = DateComponentsFormatter()..{
            if let locale = locale {
                $0.calendar = Calendar.current
                $0.calendar?.locale = locale
            }
            $0.unitsStyle = .positional
            $0.allowedUnits = allowedUnits
            $0.zeroFormattingBehavior = .pad
        }
        return formatter.string(from: components)!
    }

    private static func string(
        locale: Locale?,
        from components: DateComponents,
        unitsStyle: DateComponentsFormatter.UnitsStyle,
        maximumUnitCount: Int
    ) -> String {

        var allowedUnits: NSCalendar.Unit = []
        if let days = components.day, days != 0 {
            allowedUnits = [.day]
            if (maximumUnitCount > 1) {
                allowedUnits.insert(.hour)
            }
        } else if let hours = components.hour, hours != 0 {
            allowedUnits = [.hour]
            if (maximumUnitCount > 1) {
                allowedUnits.insert(.minute)
            }
        } else {
            allowedUnits = [.minute]
        }

        return string(locale: locale,
                                    from: components,
                                    unitsStyle: unitsStyle,
                                    maximumUnitCount: maximumUnitCount,
                                    allowedUnits: allowedUnits)
    }

    private static func string(
        locale: Locale?,
        from components: DateComponents,
        unitsStyle: DateComponentsFormatter.UnitsStyle,
        maximumUnitCount: Int,
        allowedUnits: NSCalendar.Unit
        ) -> String {

        let formatter = DateComponentsFormatter()..{
            if let locale = locale {
                $0.calendar = Calendar.current
                $0.calendar?.locale = locale
            }
            $0.unitsStyle = unitsStyle
            $0.allowedUnits = allowedUnits
            $0.maximumUnitCount = maximumUnitCount
        }
        return formatter.string(from: components)!
    }

    private static func computeComponents(from ti: TimeInterval, allowedComponents: Set<Calendar.Component> = [.day, .hour, .minute, .second]) -> DateComponents {
        let arbitraryDate = Date()
        let intervalDate = Date(timeInterval: ti, since: arbitraryDate)
        return Calendar.current.dateComponents(allowedComponents, from: arbitraryDate, to: intervalDate)
    }
}
