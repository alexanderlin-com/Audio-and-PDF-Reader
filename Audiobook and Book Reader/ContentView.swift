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

    var body: some View {
        VStack {
            Text("Audiobook Player")
                .font(.largeTitle)
                .bold()
                .padding()
            
            if let fileURL = selectedFileURL {
                Text("Selected: \(fileURL.lastPathComponent)")
                    .font(.headline)
                    .padding()
            } else {
                Text("No audiobook selected")
                    .foregroundStyle(.gray)
            }

            HStack {
                Button("Select Audiobook") {
                    showingFilePicker = true
                }
                .buttonStyle(.borderedProminent)
                
                Button(isPlaying ? "Pause" : "Play") {
                    togglePlayback()
                }
                .buttonStyle(.bordered)
                .disabled(selectedFileURL == nil)
            }
            .padding()
        }
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [UTType.audio]) { result in
            handleFileSelection(result)
        }
    }

    func handleFileSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            selectedFileURL = url
            prepareAudioPlayer()
        case .failure(let error):
            print("File selection error: \(error.localizedDescription)")
        }
    }

    func prepareAudioPlayer() {
        guard let fileURL = selectedFileURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
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
        } else {
            player.play()
            isPlaying = true
        }
    }
}

#Preview {
    ContentView()
}
