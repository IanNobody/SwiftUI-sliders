//
//  ViewController.swift/Users/simonstrycek/Documents/School/IBP/SwiftUI-sliders
//  VideoPlayerExample-UIKit
//
//  Created by Šimon Strýček on 28.03.2022.
//

import UIKit
import AVKit

class MainViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    private var videoPicker: VideoPicker!
    private var videoPlayer: VideoPlayer!
    private var loadingLabel: UILabel!
    @IBOutlet weak var mainPlayButton: UIButton!
    
    private func initVideoPicker() {
        videoPicker = VideoPicker(didFinishPicking: didFinishPicking, didLoadVideo: didLoadVideo)
    }
    
    private func initVideoPlayer() {
        videoPlayer = VideoPlayer()
        videoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.view.isHidden = true
        
        contentView.addSubview(videoPlayer.view)
        
        videoPlayer.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        videoPlayer.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        videoPlayer.view.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        videoPlayer.view.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    }
    
    private func initLoadingLabel() {
        loadingLabel = UILabel()
        loadingLabel.text = "Načítání..."
        loadingLabel.isHidden = true
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(loadingLabel)
        
        loadingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loadingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    private func initLayout() {
        initVideoPicker()
        initVideoPlayer()
        initLoadingLabel()
    }
    
    override func loadView() {
        super.loadView()
        initLayout()
    }
    
    @IBAction func selectButton(_ sender: UIButton) {
        videoPicker.pickVideo(target: self)
    }
    
    private func didFinishPicking(didSelectItem: Bool) {
        if didSelectItem {
            videoPlayer.clearContent()
            videoPlayer.view.isHidden = true
            //
            mainPlayButton.isHidden = true
            loadingLabel.isHidden = false
        }
    }
    
    private func didLoadVideo(videoUrl: URL) {
        loadingLabel.isHidden = true
        videoPlayer.view.isHidden = false
        videoPlayer.showContent(of: AVPlayer(url: videoUrl))
    }
}

