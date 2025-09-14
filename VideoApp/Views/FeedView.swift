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
    @StateObject private var playerManager = VideoPlayerManager()

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    LazyVStack(spacing: geo.safeAreaInsets.bottom) {
                        ForEach(Array(data.videos.enumerated()), id: \.element.id) { index, video in
                            VideoPostView(
                                index: index,
                                data: video,
                                player: playerManager.player(for: video)
                            )
                            .frame(height: geo.size.height)
                            .id(video.id)
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
            currentID = data.videos.first?.id
            playerManager.prefetch(around: 0, in: data.videos)
            if let first = data.videos.first { playerManager.play(videoId: first.id) }
        }
        .onChange(of: currentID) { oldValue, newValue in
            guard let newID = newValue,
                  let index = data.videos.firstIndex(where: { $0.id == newID }) else { return }
            playerManager.prefetch(around: index, in: data.videos)
            playerManager.play(videoId: newID)
        }
    }
}

#Preview {
    FeedView(data: .default)
}
