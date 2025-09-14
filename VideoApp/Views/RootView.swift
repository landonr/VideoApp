//
//  RootView.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//

import SwiftUI

struct RootView: View {
    enum ViewState {
        case loading
        case loaded(FeedElement)
        case error(String)
    }

    @State private var state: ViewState = .loading

    private let feedURL: URL
    private let autoLoad: Bool

    init(
    feedURL: URL = URL(string: "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/manifest.json")!,
        initialState: ViewState? = nil,
        autoLoad: Bool = true
    ) {
    self.feedURL = feedURL
        self.autoLoad = autoLoad
        if let initialState { self._state = State(initialValue: initialState) }
    }

    var body: some View {
        Group {
            switch state {
            case .loaded(let feed):
                FeedView(data: feed)
            case .loading:
                ProgressView("Loading…")
            case .error(let message):
                errorView(message)
            }
        }
        .task { if autoLoad { await fetch() } }
    }
    
    @ViewBuilder private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text("Failed to load videos")
                .font(.headline)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Retry") { Task { await fetch() } }
        }
        .padding()
    }

    private func fetch() async {
        state = .loading
        do {
            let feed = try await FeedElement.load(from: feedURL)
            state = .loaded(feed)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - Previews

#Preview("Loading") {
    RootView(initialState: .loading, autoLoad: false)
}

#Preview("Loaded - Default Data") {
    RootView(initialState: .loaded(.default), autoLoad: false)
}

#Preview("Error State") {
    RootView(initialState: .error("No internet connection"), autoLoad: false)
}
