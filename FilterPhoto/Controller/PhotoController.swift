//
//  PhotoController.swift
//  FilterPhoto
//
//  Created by hyunsu han on 2018. 2. 15..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import LBTAComponents

@objcMembers class PhotoController: UIViewController {

    var assets: [PHAsset] = [] {
        didSet {
            DispatchQueue.main.async { self.collectionView.reloadData() }
            // assets에 asset이 append 되는 경우에만 async
            // [PHAsset]이란 배열이 한번에 assets에 할당되는 경우에는 쓰지 않아도 된다.
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.green
        cv.delegate = self
        cv.dataSource = self
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return cv
    }()
    let reuseIdentifier: String = "PhotoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        fetchPhotos()
    }
    
    func initView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status: PHAuthorizationStatus) in
            guard let `self` = self else { return }
            switch status {
            case .denied, .notDetermined, .restricted :
                self.showAlert("설정에서 권한을 설정해주시기 바랍니다.", handler: { (action: UIAlertAction) in
                    UIApplication.shared.open(URL(string: "\(UIApplicationOpenSettingsURLString)com.hyunsoo.FilterPhoto")!, options: [:], completionHandler: nil)
                })
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                photos.enumerateObjects({ (asset: PHAsset, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    self.assets.append(asset)
                })
            }
        }
    }

}

extension PhotoController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else { return PhotoCell() }
        cell.update(data: assets[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

protocol CellProtocol: class {
    associatedtype Item
    func update(data: Item)
}

class PhotoCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        addSubview(imageView)
        imageView.anchorCenterSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.imageView.removeConstraints(self.imageView.anchorWithReturnAnchors())
    }
}

extension PhotoCell: CellProtocol {
    typealias Item = PHAsset
    func update(data: PHAsset) {
        let targetSize: CGSize = estimatedSize(data: data, isWidthLonger: data.pixelWidth > data.pixelHeight)
        
        self.imageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: targetSize.width, heightConstant: targetSize.height)
        self.imageView.updateConstraintsIfNeeded()
        
        PHImageManager.default().requestImage(for: data, targetSize: targetSize, contentMode: .aspectFill, options: nil) { [weak self] (image: UIImage?, info: [AnyHashable: Any]?) in
            guard let info = info, let image = image, let `self` = self else { return }
            
            self.imageView.image = image
            print(info)
        }
    }
    
    func estimatedSize(data: PHAsset, isWidthLonger: Bool) -> CGSize {
        return isWidthLonger ?
                CGSize(width: frame.width , height: CGFloat(data.pixelHeight) * frame.width / CGFloat(data.pixelWidth)) :
                CGSize(width: CGFloat(data.pixelWidth) * frame.height / CGFloat(data.pixelHeight) , height: frame.height)
    }
}





