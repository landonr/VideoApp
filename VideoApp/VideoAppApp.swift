//
//  VideoAppApp.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-13.
//


import AVKit
import SwiftUI

@main
struct VideoAppApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView(data: .default)
        }
    }
}
