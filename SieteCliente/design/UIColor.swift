//
//  UIColor.swift
//  SieteCliente
//
//  Created by Ricardo Paz Demiquel on 4/9/18.
//  Copyright © 2018 Ricardo Paz Demiquel. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: a
        )
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: 1
        )
    }
    
}
