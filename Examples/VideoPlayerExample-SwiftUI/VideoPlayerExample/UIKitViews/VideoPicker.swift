//
//  VideoPicker.swift
//  VideoPlayerExample
//
//  Created by Šimon Strýček on 19.03.2022.
//

import SwiftUI
import PhotosUI

struct VideoPicker: UIViewControllerRepresentable {
    var didFinishPicking: (_ didSelectItem: Bool) -> Void
    var didLoadVideo: (_ videoUrl: URL) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        
        let controller = PHPickerViewController(configuration: config)
        
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    //
    // Převzato z: https://www.appcoda.com/phpicker/
    //
    class Coordinator: PHPickerViewControllerDelegate {
        var videoPicker: VideoPicker
        
        init(with videoPicker: VideoPicker) {
            self.videoPicker = videoPicker
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            videoPicker.didFinishPicking(!results.isEmpty)
            
            guard !results.isEmpty else {
                return
            }
            
            let itemProvider = results[0].itemProvider
                
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first
            else {
                return
            }
            
            getVideo(from: itemProvider, typeIdentifier: typeIdentifier)
        }

        private func getVideo(from itemProvider: NSItemProvider, typeIdentifier: String) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }
         
                guard let url = url else { return }
         
                let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }
         
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
         
                    try FileManager.default.copyItem(at: url, to: targetURL)
         
                    DispatchQueue.main.async {
                        self.videoPicker.didLoadVideo(targetURL)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
