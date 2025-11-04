//
//  YouTubePlayerView.swift
//  Gym
//
//  Created by Mujtaba Khan on 04/11/25.
//

import SwiftUI
import AVKit
import YouTubeiOSPlayerHelper

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> YTPlayerView {
        let playerView = YTPlayerView()
        let playerVars: [AnyHashable: Any] = [
            "playsinline": 1,
            "autoplay": 1,
            "modestbranding": 1,
            "rel": 0
        ]
        playerView.load(withVideoId: videoID, playerVars: playerVars)
        return playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {}
}

struct ExercisePlayerView: View {
    let exercise: Exercise

    var body: some View {
        VStack {
            Text(exercise.name)
                .font(.title2)
                .bold()
                .padding(.top)

            if exercise.videoURL.contains("youtube.com") {
                if let id = extractYouTubeID(from: exercise.videoURL) {
                    YouTubePlayerView(videoID: id)
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding()
                } else {
                    Text("⚠️ Invalid YouTube URL")
                        .foregroundColor(.red)
                }
            } else if let url = URL(string: exercise.videoURL) {
                VideoPlayer(player: AVPlayer(url: url))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .padding()
            } else {
                Text("⚠️ Invalid video URL")
                    .foregroundColor(.red)
            }

            Spacer()
        }
    }

    private func extractYouTubeID(from url: String) -> String? {
        if let range = url.range(of: "v=") {
            let idPart = url[range.upperBound...]
            return String(idPart.split(separator: "&").first ?? "")
        } else if url.contains("youtu.be/") {
            return url.components(separatedBy: "youtu.be/").last
        }
        return nil
    }
}

