//
//  FeedElement.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//


import AVKit
import SwiftUI

struct FeedElement {
    let videos: [VideoElement]
    
    /// Default set of demo sequences for development and previews
    static let `default`: Self = .init(videos: [
        .init(
            title: "one",
            url: URL(
                string:
                    "https://naver.github.io/egjs-view360//pano/equirect/m3u8/equi.m3u8"
            )
        ),
        .init(
            title: "two",
            url: URL(
                string:
                    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8?17325"
            )
        ),
        .init(
            title: "three",
            url: URL(
                string:
                    "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8"
            )
        ),
        .init(
            title: "four",
            url: URL(
                string:
                    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8?17325"
            )
        ),
        .init(
            title: "five",
            url: URL(
                string:
                    "https://d142uv38695ylm.cloudfront.net/videos/promo/allesneu.land-promo-trailer-360p.m3u8"
            )
        ),
        .init(
            title: "six",
            url: URL(
                string:
                    "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8?17325"
            )
        ),
    ])
}
