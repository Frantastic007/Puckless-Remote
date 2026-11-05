import Carbon
import Foundation

/// Global shortcuts through Carbon, which needs no Accessibility permission.
final class Hotkeys {
    static let shared = Hotkeys()

    var handler: ((Command) -> Void)?

    private static let controlOption = UInt32(controlKey | optionKey)
    private static let controlOptionShift = UInt32(controlKey | optionKey | shiftKey)

    private let bindings: [(key: UInt32, modifiers: UInt32, command: Command)] = [
        (126, controlOption, .volumeUp),
        (125, controlOption, .volumeDown),
        (126, controlOptionShift, .bassUp),
        (125, controlOptionShift, .bassDown),
        (49, controlOption, .playPause),
        (124, controlOption, .next),
        (123, controlOption, .previous),
    ]
    private var refs: [EventHotKeyRef] = []
    private var handlerRef: EventHandlerRef?

    func enable() {
        guard refs.isEmpty else { return }
        installHandlerIfNeeded()
        for (index, binding) in bindings.enumerated() {
            var ref: EventHotKeyRef?
            let id = EventHotKeyID(signature: OSType(0x5055434B), id: UInt32(index))
            let status = RegisterEventHotKey(binding.key, binding.modifiers, id,
                                             GetApplicationEventTarget(), 0, &ref)
            if status == noErr, let ref {
                refs.append(ref)
            } else {
                Log.write("Hotkey \(binding.command.rawValue) not registered: \(status)")
            }
        }
    }

    func disable() {
        refs.forEach { UnregisterEventHotKey($0) }
        refs.removeAll()
    }

    private func installHandlerIfNeeded() {
        guard handlerRef == nil else { return }
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            var id = EventHotKeyID()
            let status = GetEventParameter(event, EventParamName(kEventParamDirectObject),
                                           EventParamType(typeEventHotKeyID), nil,
                                           MemoryLayout<EventHotKeyID>.size, nil, &id)
            if status == noErr { Hotkeys.shared.fire(Int(id.id)) }
            return noErr
        }, 1, &spec, nil, &handlerRef)
    }

    private func fire(_ index: Int) {
        guard bindings.indices.contains(index) else { return }
        handler?(bindings[index].command)
    }
}
