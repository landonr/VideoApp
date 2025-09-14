//
//  VideoPlaybackView.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//


import SwiftUI
import AVKit

public struct VideoPlaybackView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = AVPlayerViewController

    // MARK: - Configuration
    public var player: AVPlayer

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.videoGravity = .resizeAspectFill
        vc.showsPlaybackControls = false
        vc.entersFullScreenWhenPlaybackBegins = false
        vc.exitsFullScreenWhenPlaybackEnds = false
        return vc
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
