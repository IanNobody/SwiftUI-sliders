//
//  VideoPlayer.swift
//  VideoPlayerExample-UIKit
//
//  Created by Šimon Strýček on 31.03.2022.
//

import UIKit
import PreciseSlider
import AVFoundation

public class VideoPlayer: UIViewController, PreciseSliderDelegate {
    private let playImage = UIImage(
        systemName: "play.fill",
        withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
    )?.withTintColor(.tintColor, renderingMode: .alwaysOriginal)
    private let pauseImage = UIImage(
        systemName: "pause.fill",
        withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
    )?.withTintColor(.tintColor, renderingMode: .alwaysOriginal)

    private var videoPlayer: VideoView?
    private var displaylink: CADisplayLink?
    private var playbackControl: UIButton?
    private var sliderViewController: UIPreciseSliderViewController?

    public func removeSubviews() {
        videoPlayer?.removeFromSuperview()
        sliderViewController?.removeFromParent()
        sliderViewController?.view.removeFromSuperview()
        playbackControl?.removeFromSuperview()
    }

    public func setupLayout(with player: AVPlayer) {
        let videoPlayer = VideoView()
        let sliderViewController = UIPreciseSliderViewController()
        let playbackControl = UIButton()

        playbackControl.setBackgroundImage(playImage, for: .normal)
        playbackControl.addTarget(self, action: #selector(toggleVideo), for: .touchUpInside)

        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        sliderViewController.view.translatesAutoresizingMaskIntoConstraints = false
        playbackControl.translatesAutoresizingMaskIntoConstraints = false

        videoPlayer.showVideo(videoPlayer: player)
        sliderViewController.dataSource = videoPlayer
        sliderViewController.delegate = self

        sliderViewController.preciseSliderView.axisBackgroundColor =
            UITraitCollection.current.userInterfaceStyle == .dark ?
            .black : .white
        sliderViewController.preciseSliderView.unitColor = { value, _ in
            if value == videoPlayer.maxValue || value == videoPlayer.minValue {
                return .link
            }
            else {
                return UITraitCollection.current.userInterfaceStyle == .dark ?
                    .white : .black
            }
        }

        view.addSubview(videoPlayer)
        view.addSubview(sliderViewController.view)
        addChild(sliderViewController)
        view.addSubview(playbackControl)

        self.videoPlayer = videoPlayer
        self.sliderViewController = sliderViewController
        self.playbackControl = playbackControl
    }

    private func setupConstrains() {
        guard let videoPlayer = videoPlayer,
              let sliderView = sliderViewController?.view,
              let playbackControl = playbackControl
        else {
            return
        }

        NSLayoutConstraint.activate([
            videoPlayer.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoPlayer.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoPlayer.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -130),
            videoPlayer.topAnchor.constraint(equalTo: view.topAnchor),
            //
            sliderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sliderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sliderView.heightAnchor.constraint(equalToConstant: 50),
            sliderView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            //
            playbackControl.widthAnchor.constraint(equalToConstant: 40),
            playbackControl.heightAnchor.constraint(equalToConstant: 50),
            playbackControl.bottomAnchor.constraint(equalTo: sliderView.layoutMarginsGuide.topAnchor),
            playbackControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    public func showContent(of player: AVPlayer) {
        removeSubviews()
        setupLayout(with: player)
        setupConstrains()
        initDisplayLink()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    public func clearContent() {
        removeSubviews()
    }

    private func initDisplayLink() {
        if displaylink == nil {
            displaylink = CADisplayLink(target: self, selector: #selector(syncSlider))
            displaylink?.preferredFrameRateRange = .default
            displaylink?.add(to: .main, forMode: .default)
            displaylink?.isPaused = true
        }
    }

    @objc func syncSlider() {
        if sliderViewController?.isEditingValue == false {
            sliderViewController?.value = videoPlayer?.currentTime ?? Double.zero
        }
    }

    @objc func videoDidEnd() {
        playbackControl?.setBackgroundImage(playImage, for: .normal)
        displaylink?.isPaused = true
    }

    @objc func toggleVideo() {
        guard let videoPlayer = videoPlayer else {
            return
        }

        if videoPlayer.isPlaying {
            videoPlayer.pause()
            playbackControl?.setBackgroundImage(playImage, for: .normal)
            displaylink?.isPaused = true
        }
        else {
            videoPlayer.play()
            playbackControl?.setBackgroundImage(pauseImage, for: .normal)
            displaylink?.isPaused = false
        }
    }

    public func didBeginEditing() {
        videoPlayer?.pause()
        displaylink?.isPaused = true
    }

    public func valueDidChange(value: Double) {
        if videoPlayer?.isPlaying == false {
            videoPlayer?.move(to: value)
        }
    }

    public func didEndEditing() {
        guard let videoPlayer = videoPlayer else {
            return
        }

        videoPlayer.resume()
        displaylink?.isPaused = !videoPlayer.wasPlaying
    }
}
