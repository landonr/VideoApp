//
//  VideoPostView.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//


import AVKit
import SwiftUI

struct VideoPostView: View {
    let index: Int
    let data: VideoElement
    let player: AVPlayer

    var body: some View {
        ZStack {
            VideoPlaybackView(player: player)
            LinearGradient(colors: [.clear, .black.opacity(0.8)],
                           startPoint: .top,
                           endPoint: .bottom)
            .frame(height: 160)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
            VStack(alignment: .leading) { // desc
                Spacer()
                Text("Video #\(index + 1)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(32)
        }
    }
}

#Preview {
    VideoPostView(index: 0, data: .init(url: .init(string: "")), player: AVPlayer())
}
