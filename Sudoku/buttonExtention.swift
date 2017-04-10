//
//  buttonExtention.swift
//  Sudoku
//
//  Created by Spencer Kitchen on 3/6/17.
//  Copyright © 2017 wsu.vancouver. All rights reserved.
//

import UIKit



// Little bit of code to add cornerRadius, borderWidth, and border Color to UIButton
//  Will show up as variable in Interface Builder
//  Help form http://stackoverflow.com/questions/28854469/change-uibutton-bordercolor-in-storyboard

extension UIButton {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
