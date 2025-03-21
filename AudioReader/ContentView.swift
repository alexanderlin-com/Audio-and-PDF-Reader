//
//  ContentView.swift
//  AudioReader
//
//  Created by alexanderlin-com on 3/20/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var selectedFileURL: URL?
    @State private var showingFilePicker = false

    var body: some View {
        VStack(spacing: 20) {
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

            HStack {
                Button("⏪ 15s") { audioManager.rewind15Seconds() }
                    .buttonStyle(.bordered)
                    .disabled(audioManager.audioPlayer == nil)

                Button(audioManager.isPlaying ? "⏸ Pause" : "▶️ Play") {
                    audioManager.togglePlayback()
                }
                .buttonStyle(.bordered)
                .disabled(audioManager.audioPlayer == nil)

                Button("15s ⏩") { audioManager.skip15Seconds() }
                    .buttonStyle(.bordered)
                    .disabled(audioManager.audioPlayer == nil)
            }

            if audioManager.audioPlayer != nil {
                Slider(value: Binding(
                    get: { audioManager.currentTime },
                    set: { audioManager.seek(to: $0) }
                ), in: 0...audioManager.totalDuration)
                .padding(.horizontal, 20)

                Text("\(formatTime(audioManager.currentTime)) / \(formatTime(audioManager.totalDuration))")
                    .font(.subheadline)
                    .padding(.bottom, 20)
            }
        }
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [UTType.audio]) { result in
            handleFileSelection(result)
        }
    }

    private func handleFileSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                selectedFileURL = url
                audioManager.loadAudio(from: url)
            }
        case .failure(let error):
            print("File selection error: \(error.localizedDescription)")
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
