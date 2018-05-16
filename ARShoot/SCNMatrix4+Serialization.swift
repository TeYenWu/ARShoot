//
//  SCNMatrix4+Serialization.swift
//  ARShoot
//
//  Created by 吳德彥 on 15/05/2018.
//  Copyright © 2018 吳德彥. All rights reserved.
//

import Foundation
import SceneKit

extension SCNMatrix4 {
    func string() -> String {
        return "\(m11),\(m12),\(m13),\(m14),\(m21),\(m22),\(m23),\(m24),\(m31),\(m32),\(m33),\(m34),\(m41),\(m42),\(m43),\(m43),\(m44)"
    }
    
    init(dataString: String) {
        let data = dataString.split(separator: ",")
        
        self.init(m11: Float(data[0])!, m12: Float(data[1])!, m13: Float(data[2])!, m14: Float(data[3])!, m21: Float(data[4])!, m22: Float(data[5])!, m23: Float(data[6])!, m24: Float(data[7])!, m31: Float(data[8])!, m32: Float(data[9])!, m33: Float(data[10])!, m34: Float(data[11])!, m41: Float(data[12])!, m42: Float(data[13])!, m43: Float(data[14])!, m44: Float(data[15])!)
    }
}

