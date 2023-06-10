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
            title: "영수증 사진선택",
            message: "업로드할 영수증을 선택해주세요.",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let cameraAction = UIAlertAction(title: "촬영", style: .default) { _ in
            self.openCamera()
        }
        
        let albumAction = UIAlertAction(title: "앨범", style: .default) { _ in
            self.openAlbum()
        }
        
        [cameraAction, albumAction, cancelAction].forEach(alert.addAction(_:))
        present(alert, animated: true, completion: nil)
    }
    
    func showPermissionAlert(text: String) {
        let alertController = UIAlertController(
            title: "\(text) 접근 권한 필요",
            message: "\(text)에 접근하여 사진을 사용할 수 있도록 허용해주세요.",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
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
