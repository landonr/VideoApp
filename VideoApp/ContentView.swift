//
//  ContentView.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-13.
//

import AVKit
import SwiftUI

struct VideoElement: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

struct VideoPlaybackView: View {
    let data: VideoElement
    let avplayer: AVPlayer

    init(data: VideoElement) {
        self.data = data
        self.avplayer = AVPlayer(url: data.url)
    }

    var body: some View {
        VideoPlayer(player: avplayer)
//        .onAppear {
//            avplayer.play()
//        }
        .onDisappear {
            avplayer.pause()
        }
    }
}

struct VideoPostView: View {
    let data: VideoElement

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(.green)
                .overlay {
                    VideoPlaybackView(data: data)
                }
            VStack(alignment: .leading) {
                Text("Username")
                    .font(.title)
                HStack {
                    Text(data.title)
                    Spacer()
                    Text("Today")
                }
            }
            .padding(8)
        }
        .background(.white)
    }
}

struct ContentView: View {
    let data: [VideoElement] = [
        .init(
            title: "one",
            url: URL(
                string:
                    "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8"
            )!
        ),
        .init(
            title: "two",
            url: URL(
                string:
                    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8?17325"
            )!
        ),
        .init(
            title: "three",
            url: URL(
                string:
                    "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8"
            )!
        ),
        .init(
            title: "four",
            url: URL(
                string:
                    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8?17325"
            )!
        ),
        .init(
            title: "five",
            url: URL(
                string:
                    "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8"
            )!
        ),
        .init(
            title: "six",
            url: URL(
                string:
                    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8?17325"
            )!
        ),
    ]

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                LazyVStack(spacing: geo.safeAreaInsets.bottom) {
                    ForEach(data) { video in
                            VideoPostView(data: video)
                        .frame(height: geo.size.height + geo.safeAreaInsets.top)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
    }
}

#Preview {
    ContentView()
}
