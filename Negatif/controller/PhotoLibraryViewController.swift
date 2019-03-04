//
//  PhotoLibraryViewController.swift
//  Negatif
//
//  Created by Spencer  Pearlman on 3/3/19.
//  Copyright © 2019 Spencer.io. All rights reserved.
//
import UIKit
import Photos

class PhotoLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    var photoLibraryArray = [UIImage]()
    var thumbnailSize: CGSize!
    let imgPicker = UIImagePickerController()
    var selectedImage = UIImage()
    
    
    let imageManager = PHImageManager.default()
    let caching = PHCachingImageManager()
    var assets = [PHAsset]()
    
    var alreadyLoaded:Bool = true
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        activityIndicator.isHidden = true
        imgPicker.delegate = self
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let reqOptions = requestOptions()
        if let pickedAsset = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.phAsset)] as? PHAsset{
            imageManager.requestImage(for: pickedAsset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: reqOptions, resultHandler: {(image, error) in
                if let pickedImage = image{
                    self.selectedImage = pickedImage
                }
            })
        }
        nextButton.setTitleColor(UIColor(rgb: 0x318CF7), for: .normal)
        dismiss(animated: true, completion: nil)
        print("selected: \(selectedImage)")
    }
    
    @IBAction func choosePhotosFromLibrary(_ sender: Any) {
        imgPicker.allowsEditing = false
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if alreadyLoaded == true{
            let photosToBeCached = fetchImage()
            photosToBeCached.enumerateObjects({(object, count, stop) in
                self.assets.append(object)
            })
            let cacheRequestOptions = requestOptions()
            if (photosToBeCached.count > 0){
                self.caching.startCachingImages(for: assets, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: cacheRequestOptions)
            }
            print("Assets: \(assets)")
            alreadyLoaded = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        photoCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reqOptions = requestOptions()
        let cell = collectionView.cellForItem(at: indexPath)
        nextButton.setTitleColor(UIColor(rgb: 0x318CF7), for: .normal)
        cell?.layer.borderColor = UIColor(rgb: 0xFECC42).cgColor
        cell?.layer.borderWidth = 5.0
        let imgAsset = assets[indexPath.row]
        imageManager.requestImage(for: imgAsset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: reqOptions, resultHandler: {(image, error) in
            if let imageExist = image{
                self.selectedImage = imageExist
                print("didselect: \(self.selectedImage)")
            }
        })
    }
    
    @IBAction func didPressNextButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destVC = storyboard.instantiateViewController(withIdentifier: "EditImage") as! EdItImageViewController
        let image = ImageModel(filterImage: selectedImage, originalImage: selectedImage, brightness: 0, contrast: 0, shadows: 0, fade: 0, temperature: 0, sharpen: 0, saturation: 0, vibrance: 0)
        destVC.image = image.filteredImage!
        destVC.originalImage = image.originalImage
        destVC.imageModelController = ImageModelController(photo: image)
        self.present(destVC, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.layer.borderWidth = 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reqOptions = requestOptions()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        
        //convert array of assets to images to display in each cell
        let imgAsset = assets[indexPath.row]
        imageManager.requestImage(for: imgAsset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: reqOptions, resultHandler: {(image, error) in
            if let imageExist = image{
                cell.myImage.image = imageExist
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3 - 1
        return CGSize(width: width, height: width )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchImage() -> PHFetchResult<PHAsset>{
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]
        
        let imageCollection = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        print("Image count: \(imageCollection)")
        print("Image: \([imageCollection])")
        
        return imageCollection
    }
    
    func requestOptions() -> PHImageRequestOptions{
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }
    
    func cachePhotos() -> PHFetchResult<PHAsset>{
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]
        
        let imageCollection = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        print("Image count: \(imageCollection)")
        print("Image: \([imageCollection])")
        //Ensure there is at least one image in the collection
        if (imageCollection.count > 0){
            for i in 0..<imageCollection.count{
                caching.startCachingImages(for: [imageCollection[i]], targetSize: CGSize(width:200, height:200), contentMode: .aspectFit, options: requestOptions)
            }
        }
        
        return imageCollection
    }
    
    func collectPhotos() -> Void{
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        DispatchQueue.global().async {
            self.photoLibraryArray = []
            //let imageManager = PHImageManager.default()
            let caching = PHCachingImageManager()
            //PHCachingImageManager()
            //PHImageManager.default()
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending:false)]
            
            let fetchResult:PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            print("Fetch result: \(fetchResult)")
            print("Fetch Result Count: \(fetchResult)")
            
            if (fetchResult.count > 0){
                for i in 0..<fetchResult.count{
                    caching.startCachingImages(for: [fetchResult[i]], targetSize: CGSize(width:200, height:200), contentMode: .aspectFill, options: requestOptions)
                    
                }
                
                //                for i in 0..<fetchResult.count{
                //                    print("Count: \(i)")
                
                //                    caching.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:200, height:200), contentMode: .aspectFill, options: requestOptions, resultHandler: {(image,error) in
                //                        if let imageExist = image{
                //                            self.photoLibraryArray.append(imageExist)
                //                        }
                //                    })
                //}
            }else{
                print("You dont have photos")
            }
            
            DispatchQueue.main.async {
                print("Running on main queue")
                self.activityIndicator.stopAnimating()
                self.photoCollectionView.reloadData()
            }
        }
        
        
    }
    
    func refreshCollectionView(){
        self.photoCollectionView.reloadData()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
