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
    
    public func pausePlayback() {
        isPlaying = false
        player?.pause()
    }
    
    public func resumePlayback() {
        isPlaying = true
        player?.play()
    }
    
    private func initPlayer(videoUrl: URL) {
        player = AVPlayer(url: videoUrl)
        player?.addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: 0.001,
                preferredTimescale: CMTimeScale(NSEC_PER_SEC)
            ),
            queue: .main
        ) { [weak self] time in
            if self?.player?.rate != 0 && self?.player?.error == nil && self?.slider?.isEditing != true {
                self?.slider?.move(toValue: time.seconds)
            }
        }
        self.player?.actionAtItemEnd = .pause
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    @objc private func videoDidEnd() {
        isPlaying = false
    }
    
    private func initSlider() {
        guard let duration = player!.currentItem?.asset.duration.seconds
        else { return }
        
        slider = PreciseSliderViewModel(
            defaultValue: 0,
            minValue: 0,
            maxValue: duration,
            maxScale: 10.0
        )
    }
    
    public func loadVideo(videoUrl: URL) {
        initPlayer(videoUrl: videoUrl)
        initSlider()
        isLoading = false
    }
}
