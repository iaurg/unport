import UnportCore
import SwiftUI

@main
struct UnportApp: App {
    @StateObject private var store = PortStore()

    init() {
        // New status items are placed leftmost, which on a crowded menu bar is behind the notch.
        // Seed AppKit's saved position (points from the right edge) once; ⌘-drag overrides it later.
        let positionKey = "NSStatusItem Preferred Position Item-0"
        if UserDefaults.standard.object(forKey: positionKey) == nil {
            UserDefaults.standard.set(260, forKey: positionKey)
        }

        // Keeps the Dock icon hidden even when launched via `swift run`, outside the .app bundle.
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    /// Template image, so macOS tints it for light/dark menu bars and the highlighted state.
    private static let menuBarIcon: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            context.addPath(EthernetPortIcon.path(in: rect))
            context.fillPath(using: .evenOdd)
            return true
        }
        image.isTemplate = true
        return image
    }()

    var body: some Scene {
        MenuBarExtra {
            PortListView(store: store)
        } label: {
            Image(nsImage: Self.menuBarIcon)
                .accessibilityLabel("Unport")
        }
        .menuBarExtraStyle(.window)
    }
}
