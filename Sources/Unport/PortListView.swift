import SwiftUI
import UnportCore

struct PortListView: View {
    @ObservedObject var store: PortStore
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchField
            Divider()
            content
            Divider()
            footer
        }
        .frame(width: 340)
        .task {
            searchFocused = true
            // Poll only while the popover is open; the task is cancelled when it closes.
            while !Task.isCancelled {
                await store.refresh()
                try? await Task.sleep(for: .seconds(3))
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Find port or process", text: $store.query)
                .textFieldStyle(.plain)
                .focused($searchFocused)
            if !store.query.isEmpty {
                Button {
                    store.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(10)
    }

    @ViewBuilder
    private var content: some View {
        let ports = store.filteredPorts
        if ports.isEmpty {
            Text(store.query.isEmpty ? "No listening ports" : "No match for “\(store.query)”")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(ports) { port in
                        PortRow(port: port, store: store)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 360)
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let error = store.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Text("\(store.ports.count) listening")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Refresh") {
                    Task { await store.refresh() }
                }
                .keyboardShortcut("r")
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .controlSize(.small)
        }
        .padding(10)
    }
}

private struct PortRow: View {
    let port: ListeningPort
    @ObservedObject var store: PortStore
    @State private var hovering = false
    @State private var killing = false

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: ":\(port.port)")
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .frame(width: 64, alignment: .leading)

            VStack(alignment: .leading, spacing: 1) {
                Text(port.command)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(verbatim: "pid \(port.pid) · \(port.user)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            if killing {
                ProgressView().controlSize(.small)
            } else {
                iconButton("doc.on.doc", help: "Copy localhost:\(port.port)") {
                    store.copy(port)
                }
                iconButton("safari", help: "Open http://localhost:\(port.port)") {
                    store.open(port)
                }
                iconButton("xmark.circle.fill", help: "Kill \(port.command)", tint: .red) {
                    killing = true
                    Task {
                        await store.kill(port)
                        killing = false
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(hovering ? Color.primary.opacity(0.08) : .clear)
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
    }

    private func iconButton(
        _ systemName: String,
        help: String,
        tint: Color = .secondary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundStyle(tint)
                .frame(width: 22, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
        .accessibilityLabel(help)
    }
}
