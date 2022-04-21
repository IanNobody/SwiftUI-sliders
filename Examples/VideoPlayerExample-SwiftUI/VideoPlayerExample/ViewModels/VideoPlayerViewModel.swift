//
//  VideoPlayerViewModel.swift
//  VideoPlayerExample
//
//  Created by Šimon Strýček on 19.03.2022.
//

import SwiftUI
import AVKit
import PreciseSlider

class VideoPlayerViewModel: ObservableObject {
    @Published public var player: AVPlayer?
    @Published public var isPlaying: Bool = false
    @Published public var isLoading: Bool = false
    public var slider: PreciseSliderViewModel?
    public var wasPlaying: Bool = false

    private var displaylink: CADisplayLink?

    public var videoDuration: Double {
        player?.currentItem?.asset.duration.seconds ?? 0.0
    }

    public func pausePlayback() {
        player?.pause()
        displaylink?.isPaused = true
        isPlaying = false
    }

    public func resumePlayback() {
        displaylink?.isPaused = false
        player?.play()
        isPlaying = true
    }

    private func initPlayer(videoUrl: URL) {
        player = AVPlayer(url: videoUrl)

        if displaylink == nil {
            displaylink = CADisplayLink(target: self, selector: #selector(syncSlider))
            displaylink?.preferredFrameRateRange = .default
            displaylink?.add(to: .main, forMode: .default)
            displaylink?.isPaused = true
        }

        self.player?.actionAtItemEnd = .pause

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    @objc private func syncSlider() {
        guard let currentTime = player?.currentItem?.currentTime().seconds
        else { return }

        if player?.rate != 0 && player?.error == nil && slider?.isEditing != true {
            slider?.move(toValue: currentTime)
        }
    }

    @objc private func videoDidEnd() {
        isPlaying = false
    }

    private var duration: Double {
        player?.currentItem?.asset.duration.seconds ?? Double.zero
    }

    private var maxScale: Double {
        // Počet vteřin jedné jednotky * maximální měřítko jedné vteřiny
        (duration / Double(slider?.numberOfUnits ?? 20)) * 3
    }

    private func initSlider() {
        slider = PreciseSliderViewModel(
            defaultValue: 0,
            defaultScale: maxScale < 1 ? maxScale : 1,
            minValue: 0,
            maxValue: duration,
            maxScale: maxScale
        )
    }

    public func loadVideo(videoUrl: URL) {
        initPlayer(videoUrl: videoUrl)
        initSlider()
        isLoading = false
    }

    public func dropVideo() {
        player = nil
        slider = nil
        displaylink?.isPaused = true
        isLoading = false
        isPlaying = false
        wasPlaying = false
    }
}
