//
//  PhotoModelController.swift
//  Negatif
//
//  Created by Spencer  Pearlman on 2/28/19.
//  Copyright © 2019 Spencer.io. All rights reserved.
//

import UIKit
import Metal
import MetalKit
//import PhotoEditorSDK

class ImageModelController: NSObject {
    public var photo: ImageModel
    
    var device: MTLDevice?
    
    
    init(photo: ImageModel){
        self.photo = photo
    }
    
    func applyFilter(to image:UIImage, with filterEffect: ImageFilterValue) -> UIImage{
        //set up CGImage and Metal Device
        guard let cgimg = image.cgImage else{
            return UIImage(named:"14")!
            
        }
        let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice()!
        //instatiate cicontext with metal device and low priority gpu use
        let metalContext = CIContext(mtlDevice: metalDevice, options: convertToOptionalCIContextOptionDictionary([convertFromCIContextOption(CIContextOption.priorityRequestLow):true]))
        
        //let context = CIContext(eaglContext: openGLContext)
        let ciImage = CIImage(cgImage: cgimg)
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.filterEffectValue,
            let filterEffectValueName = filterEffect.filterEffectValueName{
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
        
        var filterImage: UIImage!
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
            let cgiImageResult = metalContext.createCGImage(output, from: output.extent){
            filterImage = UIImage(cgImage: cgiImageResult)
        }
        
        
        return filterImage
    }
    
    
    //Color Controls filters
    func applyBrightness(value: Float, image: UIImage?) -> UIImage{
        photo.filteredImage = image!
        
        guard var newImg = photo.filteredImage else{
            return image!
        }
        if let photoIsFiltered = photo.filteredImage{
            newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CIColorControls", filterEffectValue:  value, filterEffectValueName: kCIInputBrightnessKey))
            self.photo.brightness = value
        }
        return newImg
    }
    
    func applySatuartion(value: Float, image: UIImage?) -> UIImage{
        photo.filteredImage = image!
        
        guard var newImg = photo.filteredImage else{
            return image!
        }
        if let photoIsFiltered = photo.filteredImage{
            newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CIColorControls", filterEffectValue: value, filterEffectValueName: kCIInputSaturationKey))
            self.photo.saturation = value
        }
        return newImg

    }
    
    func applyContrst(value: Float, image:UIImage?)->UIImage{
        photo.filteredImage = image!
        guard var newImg = photo.filteredImage else{
            return image!
        }
        if let photoIsFiltered = photo.filteredImage{
            newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CIColorControls", filterEffectValue: value, filterEffectValueName: kCIInputContrastKey))
            //Saves the value of the slider for the specific filter used
            self.photo.contrast = value
        }
        return newImg
    }
    
    func applyGradient(value: Float, image: UIImage?)->UIImage{
        photo.filteredImage = image!
        guard var newImg = photo.filteredImage else{
            return image!
        }
        
        if let photoIsFiltered = photo.filteredImage{
            newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CIGaussianBlur", filterEffectValue: value, filterEffectValueName: kCIInputRadiusKey))
            //Saves the value of the slider for the specific filter used
            self.photo.fade = value
        }
        
        return newImg
    }
    func applySharpness(value: Float, image: UIImage?)->UIImage{
        photo.filteredImage = image!
        guard var newImg = photo.filteredImage else{
            return image!
        }
        if let photoIsFiltered = photo.filteredImage{
            newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CISharpenLuminance", filterEffectValue: value, filterEffectValueName: kCIInputSharpnessKey))
            self.photo.sharpen = value
        }
        return newImg
    }
    func applyTemperature(value: Float, image: UIImage?)->UIImage{
        photo.filteredImage = image!
        guard var newImg = photo.filteredImage else{
            return image!
        }
        
        if let photoIsFiltered = photo.filteredImage{
             newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CITemperatureAndTint", filterEffectValue: CIVector(x:CGFloat(value),y:100), filterEffectValueName: "inputNeutral"))
            self.photo.temperature = value
        }
        return newImg
        //Saves the value of the slider for the specific filter used
    }
    func applyVibrance(value: Float, image: UIImage?)->UIImage{
        photo.filteredImage = image!
        guard var newImg = photo.filteredImage else{
            return image!
        }
        
        if let photoIsFiltered = photo.filteredImage{
             newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CIVibrance", filterEffectValue: value, filterEffectValueName: kCIInputAmountKey))
            self.photo.vibrance = value
        }
        return newImg
    }
    func applyShadow(value: Float, image: UIImage?)->UIImage{
        photo.filteredImage = image!
        guard var newImg = photo.filteredImage else{
            return image!
        }
        
        if let photoIsFiltered = photo.filteredImage{
            newImg = applyFilter(to: photoIsFiltered, with: ImageFilterValue(filterName: "CIHighlightShadowAdjust", filterEffectValue: value, filterEffectValueName: "inputShadowAmount"))
            self.photo.shadows = value
        }
        return newImg
    }
    
//    func applyHighlights(value: Float){
//        editImage.image = image
//        guard let image = editImage.image else{
//            return
//        }
//        //not right key for filter
//        editImage.image = applyFilter(to: image, with: ImageFilterValue(filterName: "CIHighlightShadowAdjust", filterEffectValue: value, filterEffectValueName: "inputHighlightAmount"))
//        //Saves the value of the slider for the specific filter used
//        arrayOfValues["Shadows"] = value
//    }
    
    
//    func createFrameBuilder() -> [CustomPatchFrameBuilder]{
//        let dict = ["14": "png",
//                    "44": "png",
//                    "160": "png",
//                    "53": "png",
//                    "289": "png",
//                    "400": "png",
//                    "GI": "png"]
//        var configArray = [CustomPatchFrameBuilder]()
//
//        for (key, item) in dict{
//            let config = CustomPatchConfiguration()
//
//            if let url = Bundle.main.path(forResource: key+"_Top", ofType: item) {
//                let midURL = URL(fileURLWithPath: url)
//                let topImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: midURL, endImageURL: nil)
//                config.topImageGroup = topImageGroup
//            }
//
//            if let midURL = Bundle.main.url(forResource: key+"_Left", withExtension: item){
//                let leftImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: midURL, endImageURL: nil)
//                leftImageGroup.midImageMode = .stretch
//                config.leftImageGroup = leftImageGroup
//            }
//
//            if let midURL = Bundle.main.url(forResource: key+"_Right", withExtension: item){
//                let rightImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: midURL, endImageURL: nil)
//                rightImageGroup.midImageMode = .stretch
//                config.rightImageGroup = rightImageGroup
//            }
//
//            if let midURL = Bundle.main.url(forResource: key+"_Bottom", withExtension: item) {
//                let bottomImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: midURL, endImageURL: nil)
//                config.bottomImageGroup = bottomImageGroup
//            }
//
//            let builder = CustomPatchFrameBuilder(configuration: config)
//            configArray.append(builder)
//        }
//        return configArray
//    }
//
//    func createFrameFromFrameBuilder(builder: [CustomPatchFrameBuilder]) -> () {
//        let dict = ["14": "png",
//                    "44": "png",
//                    "160": "png",
//                    "53": "png",
//                    "289": "png",
//                    "400": "png",
//                    "GI-X": "png"]
//
//        for (key, item) in dict.enumerated(){
//            if let url = Bundle.main.url(forResource: item.key, withExtension: item.value) {
//                let dynamicFrame = Frame(frameBuilder: builder[key], relativeScale: 0.075, thumbnailURL: url, identifier: item.key)
//                dynamicFrame.accessibilityLabel = item.value
//                Frame.all.append(dynamicFrame)
//            }
//        }
//        for i in Frame.all{
//            print (i.identifier)
//        }
//    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
        guard let input = input else { return nil }
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
        return input.rawValue
    }

}


