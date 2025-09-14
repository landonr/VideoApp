//
//  FeedElement.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//

import AVKit
import Foundation
import SwiftUI

struct FeedElement: Decodable {
    let videos: [VideoElement]

    private enum CodingKeys: String, CodingKey { case videos }

    init(videos: [VideoElement]) {
        self.videos = videos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urls = try container.decode([URL].self, forKey: .videos)
        self.videos = urls.map { VideoElement(url: $0) }
    }

    /// Default set of demo sequences for development and previews
    static let `default`: Self = .init(videos: [
        .init(
            url: URL(
                string:
                    "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/000298e8-08bc-4d79-adfc-459d7b18edad/master.m3u8"
            )
        ),
        .init(
            url: URL(
                string:
                    "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/0042b074-1533-47f8-b370-5713d536f09b/master.m3u8"
            )
        ),
        .init(
            url: URL(
                string:
                    "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/005b2f1c-ea39-44f7-80dc-6f50334dcb3d/master.m3u8"
            )
        ),
    ])
}

extension FeedElement {
    /// Load the remote feed JSON and decode into a FeedElement
    /// - Parameter url: The URL of the feed JSON
    /// - Returns: FeedElement built from remote JSON
    static func load(from url: URL) async throws -> FeedElement {
        try await URLSession.shared.json(from: url)
    }
}
