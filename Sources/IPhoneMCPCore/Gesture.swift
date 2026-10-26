import CoreGraphics

/// What a tool asks the phone to do, in the model's coordinate space (1× screenshot pixels).
/// Each backend turns it into its own input: HID events for Mirroring, W3C actions for WebDriverAgent.
public enum Gesture: Equatable, Sendable {
    case tap(x: Double, y: Double)
    case longPress(x: Double, y: Double, ms: Int)
    case scroll(x: Double, y: Double, dy: Int)
    case swipe(x1: Double, y1: Double, x2: Double, y2: Double, ms: Int)
    case drag(x1: Double, y1: Double, x2: Double, y2: Double, holdMs: Int, ms: Int)
    case type(String)
    case key(String)          // a name from KeyCode.named
    case home, appSwitcher, spotlight
    case launchApp(String)

    /// Mirroring input: real HID events with the cursor starting at `c`.
    public func steps(_ g: PhoneGeometry, from c: CGPoint) throws -> [InputStep] {
        switch self {
        case .tap(let x, let y): return EventPlan.tap(try g.toGlobal(x: x, y: y), from: c)
        case .longPress(let x, let y, let ms): return EventPlan.longPress(try g.toGlobal(x: x, y: y), ms: ms, from: c)
        case .scroll(let x, let y, let dy): return EventPlan.scroll(at: try g.toGlobal(x: x, y: y), dy: dy, from: c)
        case .swipe(let x1, let y1, let x2, let y2, let ms):
            return EventPlan.swipe(try g.toGlobal(x: x1, y: y1), try g.toGlobal(x: x2, y: y2), durationMs: ms, from: c)
        case .drag(let x1, let y1, let x2, let y2, let hold, let ms):
            return EventPlan.drag(try g.toGlobal(x: x1, y: y1), try g.toGlobal(x: x2, y: y2), holdMs: hold, durationMs: ms, from: c)
        case .type(let s): return EventPlan.typeText(s)
        case .key(let k):
            guard let code = KeyCode.named[k] else { throw MirrorError.invalidArgument("unknown key \"\(k)\"") }
            return EventPlan.keyCombo(code)
        case .home: return EventPlan.keyCombo(KeyCode.one, [.command])
        case .appSwitcher: return EventPlan.keyCombo(KeyCode.two, [.command])
        case .spotlight: return EventPlan.keyCombo(KeyCode.three, [.command])
        case .launchApp(let name): return EventPlan.launchApp(name)
        }
    }
}
