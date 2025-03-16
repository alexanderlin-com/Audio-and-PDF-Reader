//
//  ContentView.swift
//  Audiobook and Book Reader
//
//  Created by Alex4810 on 3/11/25.
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var selectedFileURL: URL?
    @State private var showingFilePicker = false
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var totalDuration: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) { // Increased spacing for cleaner layout
            // 📂 "Add Audiobook" Button (Now at the Top)
            Button("➕ Add Audiobook") {
                showingFilePicker = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)

            if let fileURL = selectedFileURL {
                Text("📖 \(fileURL.lastPathComponent)")
                    .font(.headline)
                    .padding()
            } else {
                Text("No audiobook selected")
                    .foregroundStyle(.gray)
            }

            // 🎵 Media Controls (Centered)
            HStack {
                Button("⏪ 15s") { rewindAudio() }
                    .buttonStyle(.bordered)
                    .disabled(audioPlayer == nil)
                
                Button(isPlaying ? "⏸ Pause" : "▶️ Play") { togglePlayback() }
                    .buttonStyle(.bordered)
                    .disabled(audioPlayer == nil)

                Button("15s ⏩") { skipAudio() }
                    .buttonStyle(.bordered)
                    .disabled(audioPlayer == nil)
            }

            // 🔵 Scrub Bar (Slider to Seek Audio)
            if audioPlayer != nil {
                Slider(value: Binding(
                    get: { currentTime },
                    set: { newValue in seekToTime(newValue) }
                ), in: 0...totalDuration)
                .padding(.horizontal, 20)
            }

            // ⏳ Playback Timer
            if audioPlayer != nil {
                Text("\(formatTime(currentTime)) / \(formatTime(totalDuration))")
                    .font(.subheadline)
                    .padding(.bottom, 20)
            }
        }
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [UTType.audio]) { result in
            handleFileSelection(result)
        }
    }

    // 📂 File Selection Logic
    func handleFileSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            requestAccessAndCopyFile(originalURL: url)
        case .failure(let error):
            print("File selection error: \(error.localizedDescription)")
        }
    }

    // 🗂 File Copying & Security Access
    func requestAccessAndCopyFile(originalURL: URL) {
        let fileManager = FileManager.default
        let destinationURL = getAppSupportDirectory().appendingPathComponent(originalURL.lastPathComponent)

        if originalURL.startAccessingSecurityScopedResource() {
            defer { originalURL.stopAccessingSecurityScopedResource() }

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: originalURL, to: destinationURL)
                selectedFileURL = destinationURL
                prepareAudioPlayer()
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        } else {
            print("Failed to get access to file at \(originalURL.path)")
        }
    }

    // 🎵 Prepare Audio Player
    func prepareAudioPlayer() {
        guard let fileURL = selectedFileURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            totalDuration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }

    // ▶️ Play / Pause
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

    // 🔄 Timer for Updating Playback Time
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            currentTime = player.currentTime
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // ⏪ Rewind 15s
    func rewindAudio() {
        guard let player = audioPlayer else { return }
        let newTime = max(player.currentTime - 15, 0)
        player.currentTime = newTime
        currentTime = newTime
    }

    // ⏩ Skip 15s
    func skipAudio() {
        guard let player = audioPlayer else { return }
        let newTime = min(player.currentTime + 15, player.duration)
        player.currentTime = newTime
        currentTime = newTime
    }

    // 🎚 Seek to Specific Time via Scrub Bar
    func seekToTime(_ time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        currentTime = time
    }

    // ⏳ Convert Seconds to hh:mm:ss Format
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
    }

    // 📂 Get App Storage Directory
    func getAppSupportDirectory() -> URL {
        let fileManager = FileManager.default
        do {
            let cachesURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appDirectory = cachesURL.appendingPathComponent("AudiobookPlayer", isDirectory: true)

            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            return appDirectory
        } catch {
            fatalError("Could not access or create Caches subdirectory: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
