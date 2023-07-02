//
//  CameraAlbumAccess.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/10.
//

import Foundation
import Photos
import UIKit

// MARK: - Camera Album Access Alert
protocol CameraAlbumAccessAlertPresentable: CameraAlbumAccessable {
    func showAccessAlbumAlert(_ isShowPicker: Bool)
    func showPermissionAlert(text: String)
}

extension CameraAlbumAccessAlertPresentable {
    func showAccessAlbumAlert(_ isShowPicker: Bool) {
        let alert = UIAlertController(
            title: ConstantText.selectReceipt.localize(),
            message: ConstantText.selectReceiptText.localize(),
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: ConstantText.cancle.localize(), style: .cancel)
        let cameraAction = UIAlertAction(title: ConstantText.shooting.localize(), style: .default) { _ in
            self.openCamera()
        }
        
        let albumAction = UIAlertAction(title: ConstantText.album.localize(), style: .default) { _ in
            self.openAlbum()
        }
        
        [cameraAction, albumAction, cancelAction].forEach(alert.addAction(_:))
        present(alert, animated: true, completion: nil)
    }
    
    func showPermissionAlert(text: String) {
        let alertController = UIAlertController(
            title: ConstantText.needAccessAuth.localized(with: text),
            message: ConstantText.needAccessAuthText.localized(with: text),
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: ConstantText.deviceSetting.localize(), style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: ConstantText.cancle.localize(), style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Camera Album Access
protocol CameraAlbumAccessable where Self: UIViewController {
    func requestPHPhotoLibraryAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void)
    func requestCameraAuthorization(completion: @escaping (Bool) -> Void)
    
    func openAlbum()
    func openCamera()
}

extension CameraAlbumAccessable {
    func requestPHPhotoLibraryAuthorization(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { authorizationStatus in
            DispatchQueue.main.async {
                completion(authorizationStatus)
            }
        })
    }
    
    func requestCameraAuthorization(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { isAuth in
            DispatchQueue.main.async {
                completion(isAuth)
            }
        }
    }
}
