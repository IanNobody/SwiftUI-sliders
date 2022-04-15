//
//  VideoPlayer.swift
//  VideoPlayerExample-UIKit
//
//  Created by Šimon Strýček on 31.03.2022.
//

import UIKit
import AVFoundation
import PreciseSlider

class VideoView: UIView, PreciseSliderDataSource {
    private var playerLayer: AVPlayerLayer?
    public private(set) var wasPlaying: Bool = false

    public var currentTime: Double {
        playerLayer?.player?.currentTime().seconds ?? Double.zero
    }

    public var duration: Double {
        playerLayer?.player?.currentItem?.asset.duration.seconds ?? Double.zero
    }

    public func play() {
        if playerLayer?.player?.currentTime() == playerLayer?.player?.currentItem?.duration {
            move(to: .zero)
        }

        playerLayer?.player?.play()
    }

    public func pause() {
        wasPlaying = isPlaying
        playerLayer?.player?.pause()
    }

    public func resume() {
        if wasPlaying {
            play()
        }
    }

    public var isPlaying: Bool {
        return playerLayer?.player?.rate != 0 && playerLayer?.player?.error == nil
    }

    public func move(to time: Double) {
        playerLayer?.player?.seek(
            to:
                CMTime(
                    seconds: time,
                    preferredTimescale: CMTimeScale(NSEC_PER_SEC)
                )
        )
    }

    public func showVideo(videoPlayer: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayer.actionAtItemEnd = .pause

        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspect

        layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }

    private func valueToTimeString(value: Double, step: Double) -> String {
        let date = Date(timeIntervalSince1970: value)
        let formatter = DateFormatter()

        if step >= 1 {
            formatter.dateFormat = "m:ss"
        }
        else if step >= 0.1 {
            if duration > 60 {
                formatter.dateFormat = "m:ss.SS"
            }
            else {
                formatter.dateFormat = "s.SS"
            }
        }
        else {
            if duration > 60 {
                formatter.dateFormat = "m:ss.SSS"
            }
            else {
                formatter.dateFormat = "s.SSS"
            }
        }

        return formatter.string(from: date)
    }

    // Implementace delegáta
    public func unitLabelText(for value: Double, with stepSize: Double) -> String {
        valueToTimeString(value: value, step: stepSize)
    }

    public func unitLabelFont(for value: Double, with stepSize: Double) -> UIFont {
        UIFont.systemFont(ofSize: 9)
    }

    public func unitLabelColor(for value: Double, with stepSize: Double) -> UIColor {
        UITraitCollection.current.userInterfaceStyle == .dark ?
            .white : .black
    }

    var maxValue: Double {
        duration
    }

    var minValue: Double = 0

    var numberOfUnits: Int = 20
}
