import Foundation

/// The app's language, switchable at runtime in the settings.
enum Language: String, CaseIterable, Identifiable {
    case de, en

    var id: String { rawValue }

    var title: String {
        switch self {
        case .de: return "Deutsch"
        case .en: return "English"
        }
    }

    /// German on German systems, English everywhere else.
    static var systemDefault: Language {
        Locale.preferredLanguages.first?.hasPrefix("de") == true ? .de : .en
    }

    func text(_ german: String, _ english: String) -> String {
        self == .de ? german : english
    }
}

/// Stored as a case instead of text, so a visible notice follows a language switch.
enum Notice {
    case speakerNotFound, commandDropped

    func text(_ language: Language) -> String {
        switch self {
        case .speakerNotFound:
            return language.text("Lautsprecher nicht gefunden. Ist er aus, oder ist die mitgelieferte Fernbedienung verbunden?",
                                 "Speaker not found. Is it off, or is the supplied dial connected?")
        case .commandDropped:
            return language.text("Befehl verworfen, weil der Lautsprecher nicht rechtzeitig erreichbar war.",
                                 "Command dropped because the speaker wasn't reachable in time.")
        }
    }
}

extension ConnectionMode {
    func title(_ language: Language) -> String {
        switch self {
        case .always: return language.text("Dauerhaft", "Always on")
        case .onDemand: return language.text("Bei Bedarf", "On demand")
        }
    }
}
