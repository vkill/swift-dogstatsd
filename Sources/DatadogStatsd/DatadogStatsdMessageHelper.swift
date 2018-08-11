import func Foundation.drand48
import func Foundation.srand48
import func Foundation.time

struct DatadogStatsdMessageHelper {
    static let NEW_LINE = "\n"
    static let ESC_NEW_LINE = "\\n"
    static let COMMA = ","
    static let PIPE = "|"
    static let DOT = "."
    static let DOUBLE_COLON = "::"
    static let UNDERSCORE = "_"

    static func rand() -> Double {
        #if swift(>=4.2)
        return Double.random(in: 0...1)
        #else
        srand48(Int(time(nil)))
        return drand48()
        #endif
    }

    static func escapeNewLines(_ string: String) -> String {
        return string.replacingOccurrences(of: self.NEW_LINE, with: self.ESC_NEW_LINE)
    }

    static func removePipes(_ string: String) -> String {
        return string.replacingOccurrences(of: self.PIPE, with: "")
    }

    static func tagsAsString(_ tags: DatadogStatsdMessageTags) -> String? {
        let tags = tags.map{ self.removePipes($0).replacingOccurrences(of: self.COMMA, with: "") }
        if tags.isEmpty {
            return nil
        }
        return tags.joined(separator: self.COMMA)
    }

    //
    static func escapeEventTitle(_ string: String) -> String {
        return self.escapeNewLines(string)
    }

    static func escapeEventText(_ string: String) -> String {
        return self.escapeNewLines(string)
    }

    //
    static func escapeServiceCheckMessage(_ string: String) -> String {
        var escapedMessage = self.removePipes(string)
        escapedMessage = self.escapeNewLines(escapedMessage)
        return escapedMessage.replacingOccurrences(of: "m:", with: "m\\:")
    }

    //
    static func escapeMetricName(_ string: String) -> String {
        var escapedName = string.replacingOccurrences(of: self.DOUBLE_COLON, with: self.DOT)
        escapedName = escapedName.replacingOccurrences(of: ":", with: self.UNDERSCORE)
        escapedName = escapedName.replacingOccurrences(of: "|", with: self.UNDERSCORE)
        return escapedName.replacingOccurrences(of: "@", with: self.UNDERSCORE)
    }

    //
    static func assertMetricSampleRate(_ sampleRate: Double) {
        assert((0.0...1.0).contains(sampleRate), "sampleRate require to be in range 0.0...1.0")
    }
}
