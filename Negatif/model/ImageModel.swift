//
//  ImageModel.swift
//  Negatif
//
//  Created by Spencer  Pearlman on 2/28/19.
//  Copyright © 2019 Spencer.io. All rights reserved.
//

import Foundation
import UIKit

struct ImageModel{
    var filteredImage: UIImage?
    var originalImage: UIImage?
    var brightness: Float?
    var contrast: Float?
    var shadows: Float?
    var fade: Float?
    var temperature: Float?
    var sharpen: Float?
    var saturation: Float?
    var vibrance: Float?
    
    init(filterImage: UIImage, originalImage: UIImage, brightness: Float?, contrast: Float?, shadows: Float?, fade: Float?, temperature: Float?, sharpen: Float?, saturation: Float?, vibrance: Float?){
        self.filteredImage = filterImage
        self.originalImage = originalImage
        self.brightness = brightness
        self.contrast = contrast
        self.shadows = shadows
        self.fade = fade
        self.temperature = temperature
        self.sharpen = sharpen
        self.saturation = saturation
        self.vibrance = vibrance
    }
}
