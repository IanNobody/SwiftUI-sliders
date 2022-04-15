//
//  VideoPicker.swift
//  VideoPlayerExample-UIKit
//
//  Created by Šimon Strýček on 30.03.2022.
//

import PhotosUI

class VideoPicker: PHPickerViewControllerDelegate {
    var didFinishPicking: (_ didSelectItem: Bool) -> Void
    var didLoadVideo: (_ videoUrl: URL) -> Void

    public init(
        didFinishPicking: @escaping (_ didSelectItem: Bool) -> Void,
        didLoadVideo: @escaping (_ videoUrl: URL) -> Void
    ) {
        self.didFinishPicking = didFinishPicking
        self.didLoadVideo = didLoadVideo
    }

    public func pickVideo(target: UIViewController) {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current

        let controller = PHPickerViewController(configuration: config)

        controller.delegate = self
        target.present(controller, animated: true)
    }

    //
    // Převzato z: https://www.appcoda.com/phpicker/
    //
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        didFinishPicking(!results.isEmpty)

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
                    self.didLoadVideo(targetURL)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
