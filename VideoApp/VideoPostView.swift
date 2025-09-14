//
//  VideoPostView.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//


import AVKit
import SwiftUI

struct VideoPostView: View {
    let data: VideoElement
    let player: AVPlayer

    var body: some View {
        ZStack {
            VideoPlaybackView(player: player)
            VStack(alignment: .leading) {
                Spacer()
                Text("Username")
                    .font(.title)
                HStack {
                    Text(data.title)
                    Spacer()
                    Text("Today")
                }
            }
            .padding()
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    VideoPostView(data: .init(title: "Test Video", url: .init(string: "")), player: AVPlayer())
}
