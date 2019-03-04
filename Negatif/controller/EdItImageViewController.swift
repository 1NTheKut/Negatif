//
//  EdItImageViewController.swift
//  Negatif
//
//  Created by Spencer  Pearlman on 3/3/19.
//  Copyright © 2019 Spencer.io. All rights reserved.
//

import UIKit
import CropViewController
import Metal
import MetalKit

class EdItImageViewController: UIViewController{
    
    var imageModelController: ImageModelController!
    
    @IBOutlet var editImage: UIImageView!
    var image = UIImage()
    //Variable to hold imageview's image before editing
    var revertBackToImage: UIImage?
    
    @IBOutlet var container: UIView!
    @IBOutlet var filterCollectionView: UICollectionView!
    var didShowFilters = true
    @IBOutlet var showFilters: UIButton!
    @IBOutlet var showEffects: UIButton!
    
    @IBOutlet var sliderViewEffects: UIView!
    @IBOutlet var showFeaturesCollectionView: UICollectionView!
    
    @IBOutlet var titleName: UILabel!
    @IBOutlet var filterSlider: UISlider!
    fileprivate var ciImageContext: CIContext!
    
    @IBOutlet var dismissVCButton: UIButton!
    
    
    //image to be edited
    public var coreImage: CIImage!
    
    var originalImage: UIImage?
    
    var filterNumber:Int = 0
    
    var device: MTLDevice?
    
    var didReset: Bool?
    
    var imageNames: [String] = ["14 - Inactive", "44 - Inactive", "53 (InActive)", "160 - - Inactive", "289  - Inactive", "400 - Inactive", "GI-X (InActive)"]
    
    var imageActiveNames: [String] = ["14 - Active", "44 - Active", "53 (Active)", "160 - Active", "289 - Active", "400 - Active", "GI-X (Active)"]
    
    var filterNames: [String] = ["Adjust", "Brightness", "Contrast", "Highlights", "Shadows", "Fade", "Temperature", "Sharpen", "Saturation", "Vibrance"]
    
    override func viewWillAppear(_ animated: Bool) {
        editImage.image = image
    }
    
    override func viewDidLoad() {
        //Setting the delegate and data source
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        
        //Setting the delegate and data source
        showFeaturesCollectionView.delegate = self
        showFeaturesCollectionView.dataSource = self
        
        showFeaturesCollectionView.isHidden = true
        sliderViewEffects.isHidden = true
        
        editImage.clipsToBounds = true
        editImage.contentMode = UIView.ContentMode.scaleAspectFit
        
        device = MTLCreateSystemDefaultDevice()
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        guard editImage.image != nil else{
            return
        }
        _ = image
        let size = editImage.image?.size
        UIGraphicsBeginImageContext(size!)
        
        let areaSize = CGRect(x: 0, y: 0, width: (size?.width)!, height: (size?.height)!)
        editImage!.image?.draw(in: areaSize)
        
        var newI:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageData = newI.pngData()
        let compressedImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        
        let alert = UIAlertController(title: "Saved", message: "Your photo has been saved", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    //Shows the filter collection view
    @IBAction func showFilter(_ sender: Any) {
        let image = UIImage(named: "Filters Active")
        let effects = UIImage(named: "Effects Inactive")
        showFilters.setImage(image, for: UIControl.State.normal)
        showEffects.setImage(effects, for: UIControl.State.normal)
        titleName.text = "Filters"
        showFeaturesCollectionView.isHidden = true
        filterCollectionView.isHidden = false
        didShowFilters = true
    }
    
    //Shows the adjustment collection view
    @IBAction func showEffects(_ sender: Any) {
        let image = UIImage(named: "Filters Inactive")
        let effects = UIImage(named: "Effects Active")
        showFilters.setImage(image, for: UIControl.State.normal)
        showEffects.setImage(effects, for: UIControl.State.normal)
        titleName.text = "Adjustments"
        showFeaturesCollectionView.isHidden = false
        filterCollectionView.isHidden = true
        showFeaturesCollectionView.reloadData()
        didShowFilters = false
    }
    
    @IBAction func didTapSliderButton(_ sender: UISlider) {
        let sliderValue = sender.value
        
        switch filterNumber{
        case 1:
            editImage.image = imageModelController.applyBrightness(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        case 2:
            editImage.image = imageModelController.applyContrst(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        case 3:
            //            editImage.image = imageModelController.applyHighlights(value: sliderValue, image: imageModelController.photo.filteredImage)
            print("Not implemented")
            break
        case 4:
            editImage.image = imageModelController.applyShadow(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        case 5:
            editImage.image = imageModelController.applyGradient(value: sliderValue, image:imageModelController.photo.filteredImage)
            break
        case 6:
            editImage.image = imageModelController.applyTemperature(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        case 7:
            editImage.image = imageModelController.applySharpness(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        case 8:
            editImage.image = imageModelController.applySatuartion(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        case 9:
            editImage.image = imageModelController.applyVibrance(value: sliderValue, image: imageModelController.photo.filteredImage)
            break
        default:
            editImage.image = imageModelController.applyBrightness(value: sliderValue, image: imageModelController.photo.filteredImage)
        }
        
    }
    
    @IBAction func resetFilters(_ sender: Any) {
        editImage.image = imageModelController.photo.originalImage
        imageModelController.photo.filteredImage = imageModelController.photo.originalImage
    }
    
    @IBAction func didPressCancelButton(_ sender: Any) {
        editImage.image = revertBackToImage
        sliderViewEffects.isHidden = true
    }
    
    @IBAction func didPressDoneEditingImage(_ sender: Any) {
        sliderViewEffects.isHidden = true
    }
    
    @IBAction func didDismissViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
        guard let input = input else { return nil }
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
        return input.rawValue
    }
    
}

extension EdItImageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (didShowFilters == true){
            return imageNames.count
        }else{
            print("Count: \(filterNames.count)")
            return filterNames.count
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (didShowFilters == true){
            let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "editedCell", for: indexPath) as! FilterCell
            cell.filteredImage.image = UIImage(named: imageNames[indexPath.row])
            return cell
        }else{
            let cell = showFeaturesCollectionView.dequeueReusableCell(withReuseIdentifier: "filter", for: indexPath) as! EffectsCell
            cell.effects.image = UIImage(named:filterNames[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (didShowFilters == true){
            let cell = collectionView.cellForItem(at: indexPath) as! FilterCell
            cell.filteredImage.image = UIImage(named: imageActiveNames[indexPath.row])
        }else{
            for name in filterNames{
                if name == filterNames[indexPath.row]{
                    titleName.text = filterNames[indexPath.row]
                    sliderViewEffects.isHidden = false
                }
            }
            switch indexPath.row{
            case 0:
                presentCropViewController()
                sliderViewEffects.isHidden = true
                break
            case 1:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 1
                filterSlider.minimumValue = -0.75
                filterSlider.maximumValue = 0.75
                filterSlider.value = imageModelController.photo.brightness!
                break
            case 2:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 2
                filterSlider.minimumValue = 0.0
                filterSlider.maximumValue = 2.0
                filterSlider.value = imageModelController.photo.contrast!
                break
            case 3:
                //                revertBackToImage = editImage.image
                //                filterNumber = 3
                //                filterSlider.minimumValue = 0.0
                //                filterSlider.maximumValue = 2.0
                //                filterSlider.value = imageModel
                print("Not yet implemented")
                break
            case 4:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 4
                filterSlider.minimumValue = 0.50
                filterSlider.maximumValue = 2.0
                filterSlider.value = imageModelController.photo.shadows!
                break
            case 5:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 5
                filterSlider.minimumValue = 0.0
                filterSlider.maximumValue = 20.0
                filterSlider.value = imageModelController.photo.fade!
                break
            case 6:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 6
                filterSlider.minimumValue = 4500.0
                filterSlider.maximumValue = 9000.0
                filterSlider.value = imageModelController.photo.temperature!
                break
            case 7:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 7
                filterSlider.minimumValue = 0.20
                filterSlider.maximumValue = 2.0
                filterSlider.value = imageModelController.photo.sharpen!
                break
            case 8:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 8
                filterSlider.minimumValue = -0.50
                filterSlider.maximumValue = 1.50
                filterSlider.value = imageModelController.photo.saturation!
                break
            case 9:
                revertBackToImage = imageModelController.photo.filteredImage
                filterNumber = 9
                filterSlider.minimumValue = -0.50
                filterSlider.maximumValue = 1.50
                filterSlider.value = imageModelController.photo.vibrance!
                break
            default:
                print("No filters picked")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //Sets the new filtered image in the image view to the image that will be the source for filtering in the
        //filter methods
        imageModelController.photo.filteredImage = editImage.image!
        
        if (didShowFilters == true){
            let cell = collectionView.cellForItem(at: indexPath) as! FilterCell
            cell.filteredImage.image = UIImage(named: imageNames[indexPath.row])
        }else{
            print("Deselect at \(indexPath.row)")
        }
    }
}

extension EdItImageViewController: CropViewControllerDelegate{
    func presentCropViewController(){
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        dismiss(animated: true, completion: {() in
            self.editImage.image = image
        })
    }
    
    public func adjustImageView(_ image: UIImage) -> UIImageView{
        let ratio = image.size.width / image.size.height
        if container.frame.width > container.frame.height{
            let newHeight = container.frame.width / ratio
            editImage.frame.size = CGSize(width: container.frame.width, height: newHeight)
        }else{
            let newWidth = container.frame.height * ratio
            editImage.frame.size = CGSize(width: newWidth, height: container.frame.height)
        }
        
        return editImage
    }
}
