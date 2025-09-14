//
//  FeedView.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//


import AVKit
import SwiftUI

struct FeedView: View {
    let data: FeedElement
    // Track the currently visible item's ID (updated by ScrollView paging)
    @State private var currentID: UUID?
    // Keep one AVPlayer per video (array aligns with data.videos indices)
    @State private var players: [AVPlayer] = []

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    LazyVStack(spacing: geo.safeAreaInsets.bottom) {
                        ForEach(Array(data.videos.enumerated()), id: \.element.id) { index, video in
                            VideoPostView(
                                data: video,
                                player: index < players.count ? players[index] : AVPlayer()
                            )
                            .frame(
                                height: geo.size.height
//                                            + geo.safeAreaInsets.top
                            )
                            .background(.red)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $currentID)
                .scrollTargetBehavior(.paging)
            }
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .onAppear {
            // Initialize players array to match videos count
            if players.count != data.videos.count {
                players = data.videos.map { _ in AVPlayer() }
            }
            currentID = data.videos.first?.id
        }
        .onChange(of: currentID) { _, newValue in
            guard let newValue,
                  let currentIndex = data.videos.firstIndex(where: { $0.id == newValue }) else { return }

            // Pause all players first (avoid multiple playing)
            for p in players { p.pause() }

            // Helper to set (or clear) item for index
            func setItem(for index: Int, play: Bool = false) {
                guard players.indices.contains(index) else { return }
                let url = data.videos[index].url
                if let url {
                    let item = AVPlayerItem(url: url)
                    players[index].replaceCurrentItem(with: item)
                    if play { players[index].play() }
                } else {
                    players[index].replaceCurrentItem(with: nil)
                }
            }

            // Current video: set and play
            setItem(for: currentIndex, play: true)

            // Simple prefetching: prepare previous and next items (don’t play)
            let prev = currentIndex - 1
            let next = currentIndex + 1
            if prev >= 0 { setItem(for: prev, play: false) }
            if next < data.videos.count { setItem(for: next, play: false) }

            // Optionally clear far-away players to save memory
            for idx in players.indices where abs(idx - currentIndex) > 1 {
                players[idx].replaceCurrentItem(with: nil)
            }
        }
    }
}

#Preview {
    FeedView(data: .default)
}
