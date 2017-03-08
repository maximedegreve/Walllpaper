//
//  Double.swift
//  Walllpaper
//
//  Created by Maxime De Greve on 19/02/2017.
//
//

import Foundation

extension Double {
    
    func roundUp() -> Int {
        if self == Double(Int(self)) {
            return Int(self)
        } else if self < 0 {
            return Int(self)
        } else {
            return Int(self) + 1
        }
    }
    
}
