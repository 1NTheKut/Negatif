//
//  ImageFilter.swift
//  Negatif
//
//  Created by Spencer  Pearlman on 2/28/19.
//  Copyright © 2019 Spencer.io. All rights reserved.
//

import Foundation
import UIKit

protocol Filter{
    var name: String { get }
    func apply(input: UIImage) -> UIImage
}

protocol ImageFilter: Filter{
}


struct ImageFilterValue {
    let filterName: String
    var filterEffectValue: Any?
    var filterEffectValueName: String?
    
    init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?){
        self.filterName = filterName
        self.filterEffectValue = filterEffectValue
        self.filterEffectValueName = filterEffectValueName
    }
}
