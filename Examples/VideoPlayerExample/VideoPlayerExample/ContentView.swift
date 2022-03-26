//
//  ContentView.swift
//  VideoPlayerExample
//
//  Created by Šimon Strýček on 18.03.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var videoViewModel = VideoPlayerViewModel()
    @State var showPicker = false
    
    var body: some View {
        VStack {
            HStack {
                Button("Vybrat video...") {
                    videoViewModel.pausePlayback()
                    showPicker = true
                }
                .offset(x: 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if videoViewModel.player != nil,
               let slider = videoViewModel.slider {
                VideoPlayer(
                    videoViewModel: videoViewModel,
                    sliderViewModel: slider
                )
            }
            else if videoViewModel.isLoading {
                Text("Načítání...")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                Button(
                    action: {
                        showPicker = true
                    },
                    label: {
                        Image(systemName: "play.circle")
                            .font(.system(size: 100, weight: .medium))
                            .foregroundColor(.primary)
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showPicker) {
            VideoPicker(
                didFinishPicking: { didSelectItems in
                    showPicker = false
                    videoViewModel.isLoading = didSelectItems
                    
                    if didSelectItems {
                        videoViewModel.dropVideo()
                    }
                },
                didLoadVideo: { videoUrl in
                    videoViewModel.loadVideo(videoUrl: videoUrl)
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
