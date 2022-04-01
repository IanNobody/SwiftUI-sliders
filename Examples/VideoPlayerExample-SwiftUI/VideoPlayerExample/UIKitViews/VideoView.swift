//
//  VideoPlayer.swift
//  VideoPlayerExample
//
//  Created by Šimon Strýček on 19.03.2022.
//

import SwiftUI
import AVKit

struct VideoView: UIViewRepresentable {
    @Binding var videoPlayer: AVPlayer?
    let frame: CGRect
    
    func makeUIView(context: Context) -> some UIView {
        guard let videoPlayer = videoPlayer else {
            return UIView()
        }

        let view = UIView(frame: frame)
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = view.frame
        playerLayer.videoGravity = .resizeAspect
        
        view.layer.addSublayer(playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.layer.frame = uiView.frame
    }
}
