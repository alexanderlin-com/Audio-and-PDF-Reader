//
//  AudioPlayerManager.swift
//  AudioReader
//
//  Created by alexanderlin-com on 3/20/25.
//

import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    
    private var timer: Timer?

    func loadAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            totalDuration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }

    func togglePlayback() {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopTimer()
        } else {
            player.play()
            isPlaying = true
            startTimer()
        }
    }

    func rewind15Seconds() {
        guard let player = audioPlayer else { return }
        player.currentTime = max(player.currentTime - 15, 0)
        currentTime = player.currentTime
    }

    func skip15Seconds() {
        guard let player = audioPlayer else { return }
        player.currentTime = min(player.currentTime + 15, player.duration)
        currentTime = player.currentTime
    }

    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        currentTime = time
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
