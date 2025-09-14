//
//  VideoPlayerManager.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//

import AVKit
import Foundation

/// Manages one AVPlayer per video and provides lightweight prefetching.
final class VideoPlayerManager: ObservableObject {
    /// Cache of players keyed by VideoElement.id
    private var players: [UUID: AVPlayer] = [:]
    /// Keep track of in-flight prerolls to avoid duplication
    private var prerolling: Set<UUID> = []
    /// KVO observers for player.status keyed by VideoElement.id
    private var playerStatusObservers: [UUID: NSKeyValueObservation] = [:]
    /// KVO observers for item.status keyed by VideoElement.id
    private var itemStatusObservers: [UUID: NSKeyValueObservation] = [:]
    /// Notification observers for item end to loop playback
    private var itemEndObservers: [UUID: Any] = [:]

    /// Radius around the current index to prefetch.
    var prefetchRadius: Int = 2

    /// Retrieve (or create) a dedicated player for the given video.
    func player(for video: VideoElement) -> AVPlayer {
        if let existing = players[video.id] { return existing }

        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = true

        if let url = video.url {
            let item = AVPlayerItem(url: url)
            item.preferredForwardBufferDuration = 1  // seconds to buffer ahead when possible
            player.replaceCurrentItem(with: item)
            // Loop at end to avoid a black frame when revisiting
            player.actionAtItemEnd = .none
            // Remove any existing end observer for this id (defensive)
            if let token = itemEndObservers[video.id] { NotificationCenter.default.removeObserver(token) }
            itemEndObservers[video.id] = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
            }
        }

        players[video.id] = player
        return player
    }

    /// Prepare players around the current index for smoother transitions.
    func prefetch(around currentIndex: Int?, in videos: [VideoElement]) {
        guard let idx = currentIndex else { return }
        let lower = max(0, idx - prefetchRadius)
        let upper = min(videos.count - 1, idx + prefetchRadius)
        guard lower <= upper else { return }

        for i in lower...upper {
            let video = videos[i]
            let player = player(for: video)
            // Kick off preroll (only when ready)
            queuePrerollIfReady(video: video, player: player)
        }
        // Optionally trim far-away players to keep memory bound (simple heuristic: keep window of radius*2+1)
        trimCache(keeping: Set((lower...upper).map { videos[$0].id }))
    }

    /// Start playback for a specific video and pause others.
    func play(videoId: UUID) {
        for (id, player) in players {
            if id == videoId {
                player.play()
            } else {
                player.pause()
                player.seek(to: .zero)
            }
        }
    }

    /// Pause all players.
    func pauseAll() {
        for (_, player) in players { player.pause() }
    }

    /// Remove players that are not within the keep set to reduce memory.
    private func trimCache(keeping keepIDs: Set<UUID>) {
        let toRemove = players.keys.filter { !keepIDs.contains($0) }
        for id in toRemove {
            if let player = players.removeValue(forKey: id) {
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
            // Clean up any observers & preroll state
            playerStatusObservers[id]?.invalidate()
            playerStatusObservers[id] = nil
            itemStatusObservers[id]?.invalidate()
            itemStatusObservers[id] = nil
            if let token = itemEndObservers[id] {
                NotificationCenter.default.removeObserver(token)
            }
            itemEndObservers[id] = nil
            prerolling.remove(id)
        }
    }

    deinit {
        // Invalidate observers to avoid KVO crashes
    for (_, obs) in playerStatusObservers { obs.invalidate() }
        playerStatusObservers.removeAll()
    for (_, obs) in itemStatusObservers { obs.invalidate() }
    itemStatusObservers.removeAll()
    for (_, token) in itemEndObservers { NotificationCenter.default.removeObserver(token) }
    itemEndObservers.removeAll()
    }

    // MARK: - Helpers
    private func queuePrerollIfReady(video: VideoElement, player: AVPlayer) {
        guard video.url != nil else { return }
        // Already prerolling or ready? Avoid duplicates
        if prerolling.contains(video.id) { return }

        let startPreroll = { [weak self] in
            guard let self = self else { return }
            if self.prerolling.contains(video.id) { return }
            self.prerolling.insert(video.id)
            player.preroll(atRate: 1.0) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.prerolling.remove(video.id)
                }
            }
        }

        // Prefer item readiness for preroll
        guard let item = player.currentItem else { return }

        switch item.status {
        case .readyToPlay:
            startPreroll()
            return
        case .failed:
            return
        case .unknown:
            break
        @unknown default:
            break
        }

        // Observe item status changes; use initial + new for immediate readiness
        itemStatusObservers[video.id]?.invalidate()
        itemStatusObservers[video.id] = item.observe(
            \.status,
            options: [.initial, .new]
        ) { [weak self] item, _ in
            guard let self = self else { return }
            if item.status == .readyToPlay {
                self.itemStatusObservers[video.id]?.invalidate()
                self.itemStatusObservers[video.id] = nil
                startPreroll()
            } else if item.status == .failed {
                self.itemStatusObservers[video.id]?.invalidate()
                self.itemStatusObservers[video.id] = nil
            }
        }
    }
}
