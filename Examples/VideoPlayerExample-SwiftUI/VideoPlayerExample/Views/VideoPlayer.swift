//
//  VideoPlayer.swift
//  VideoPlayerExample
//
//  Created by Šimon Strýček on 19.03.2022.
//

import SwiftUI
import AVKit
import PreciseSlider

struct VideoPlayer: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var videoViewModel: VideoPlayerViewModel
    @ObservedObject var sliderViewModel: PreciseSliderViewModel

    var body: some View {
        if videoViewModel.player != nil {
            GeometryReader { proxy in
                VideoView(videoPlayer: $videoViewModel.player, frame: proxy.frame(in: .local))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //
            HStack {
                Button(
                    action: {
                        if videoViewModel.isPlaying {
                            videoViewModel.pausePlayback()
                        }
                        else {
                            if videoViewModel.player?.currentTime() == videoViewModel.player?.currentItem?.duration {
                                videoViewModel.player?.seek(to: CMTime.zero)
                            }

                            videoViewModel.resumePlayback()
                        }
                    },
                    label: {
                        Image(systemName: videoViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 40, weight: .medium))
                    }
                )
            }
            .frame(height: 50, alignment: .center)
            //
            PreciseSliderView(
                viewModel: sliderViewModel,
                valueLabel: { value, step in
                    Text("\(valueToTimeString(value: value, step: step))")
                        .font(.system(size: 9))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            )
            .frame(height: 50)
            .onChange(of: sliderViewModel.isEditing) { isEditing in
                let value = sliderViewModel.value

                if isEditing {
                    videoViewModel.wasPlaying = videoViewModel.isPlaying
                    videoViewModel.player?.pause()
                }
                else if videoViewModel.wasPlaying {
                    videoViewModel.player?.play()
                }

                videoViewModel.player?.seek(
                    to: .init(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                    toleranceBefore: CMTime.zero,
                    toleranceAfter: CMTime.zero
                )
            }
            .preciseSliderStyle(
                PreciseSliderStyle(
                    backgroundColor: Color(UIColor.systemBackground),
                    unitColor: { value, _ in
                        if value == sliderViewModel.minValue || value == sliderViewModel.maxValue {
                            return .blue
                        }
                        else {
                            return colorScheme == .dark ? .white : .black
                        }
                    }
                )
            )
        }
    }

    private func valueToTimeString(value: Double, step: Double) -> String {
        let date = Date(timeIntervalSince1970: value)
        let formatter = DateFormatter()

        if step >= 1 {
            formatter.dateFormat = "m:ss"
        }
        else if step >= 0.1 {
            if videoViewModel.videoDuration > 60 {
                formatter.dateFormat = "m:ss.SS"
            }
            else {
                formatter.dateFormat = "s.SS"
            }
        }
        else {
            if videoViewModel.videoDuration > 60 {
                formatter.dateFormat = "m:ss.SSS"
            }
            else {
                formatter.dateFormat = "s.SSS"
            }
        }

        return formatter.string(from: date)
    }
}

/*
struct VideoPlayer_Previews: PreviewProvider {
    @State var viewModel = VideoPlayerViewModel()
    
    static var previews: some View {
        VideoPlayer(viewModel: $viewModel)
    }
}
 */
