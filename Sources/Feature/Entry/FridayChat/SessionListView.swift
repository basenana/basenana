//
//  SessionListView.swift
//  Feature
//
//  Session list view for Friday Chat
//

import SwiftUI
import Domain

public struct SessionListView: View {
    let sessions: [FridaySession]
    let currentSession: FridaySession?
    let onSelect: (FridaySession) -> Void
    let onDelete: (FridaySession) -> Void

    public init(
        sessions: [FridaySession],
        currentSession: FridaySession?,
        onSelect: @escaping (FridaySession) -> Void,
        onDelete: @escaping (FridaySession) -> Void
    ) {
        self.sessions = sessions
        self.currentSession = currentSession
        self.onSelect = onSelect
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Sessions")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if sessions.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No sessions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Start a new conversation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List(sessions, id: \.id) { session in
                    SessionRowView(
                        session: session,
                        isSelected: currentSession?.id == session.id,
                        onSelect: { onSelect(session) },
                        onDelete: { onDelete(session) }
                    )
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct SessionRowView: View {
    let session: FridaySession
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onSelect) {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : .secondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.name)
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .white : .primary)
                            .lineLimit(1)

                        Text(formatDate(session.updatedAt))
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.7) : .secondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            if isSelected {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
            }

            Menu {
                Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(4)
            }
            .menuStyle(.borderlessButton)
            .help("More actions")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .confirmationDialog(
            "Delete Session",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(session.name)\"? This action cannot be undone.")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today " + date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday " + date.formatted(date: .omitted, time: .shortened)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
}
