//
//  ContentView.swift
//  Audio Bookmark Example App
//
//  Created by Bill Skrzypczak on 4/6/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var bookmarkTime: TimeInterval = 0
    @State private var isPlaying = false
    @State private var progress: Double = 0.0
    @State private var playbackTimer: Timer?
    @State private var userIsDraggingSlider = false

    var body: some View {
        VStack(spacing: 20) {
            Slider(value: $progress, in: 0...1, onEditingChanged: sliderEditingChanged)
                .accentColor(.blue)
                .padding()
            
            HStack(spacing: 10) {
                Button("Play") {
                    playAudio()
                }
                Button("Pause") {
                    pauseAudio()
                }
                Button("Rewind") {
                    rewindAudio()
                }
                Button("Bookmark") {
                    setBookmark()
                }
                Button("Play from Bookmark") {
                    playFromBookmark()
                }
            }
        }
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }
    }

    func setupAudioPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            guard let path = Bundle.main.path(forResource: "Americana", ofType:"mp3") else { return }
            let url = URL(fileURLWithPath: path)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Audio session or player initialization failed: \(error)")
        }
    }

    func playAudio() {
        guard let player = audioPlayer else { return }
        if !player.isPlaying {
            player.play()
            isPlaying = true
            startPlaybackTimer()
        }
    }

    func pauseAudio() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.pause()
        isPlaying = false
        bookmarkTime = player.currentTime
        playbackTimer?.invalidate()
    }

    func rewindAudio() {
        guard let player = audioPlayer else { return }
        player.currentTime = 0
        progress = 0
        if isPlaying {
            player.play()
        } else {
            updateProgress()
        }
    }

    func setBookmark() {
        guard let player = audioPlayer else { return }
        bookmarkTime = player.currentTime
    }

    func playFromBookmark() {
        guard let player = audioPlayer else { return }
        player.currentTime = bookmarkTime
        player.play()
        isPlaying = true
        startPlaybackTimer()
    }

    func startPlaybackTimer() {
        playbackTimer?.invalidate() // Invalidate any existing timer
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !self.userIsDraggingSlider {
                self.updateProgress()
            }
        }
    }

    func updateProgress() {
        guard let player = audioPlayer else { return }
        self.progress = player.currentTime / player.duration
    }

    func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            userIsDraggingSlider = true
        } else {
            // Seek to the new time
            if let duration = audioPlayer?.duration {
                let newTime = duration * progress
                audioPlayer?.currentTime = newTime
                userIsDraggingSlider = false
                
                // If the player was playing, continue playing at the new time
                if isPlaying {
                    audioPlayer?.play()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
}
