//
//  Extensions.swift
//  weatherSharingApp
//
//  Created by user on 3/7/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import UIKit


extension UIImage {
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}


extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension CAGradientLayer {
    
    public func createGradientLayer(withColors colors:(CGColor, CGColor)) -> CAGradientLayer {
        self.colors = [colors.0, colors.1]
        self.name = "Vasya"
        self.startPoint = CGPoint.init(x: 0.5, y: 0.0)
        self.endPoint = CGPoint.init(x: 0.5, y: 1.0)
        return self
    }
}

extension UIView {
    
    func shake(animationValues values: [Any]?, duration: CFTimeInterval) {
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = duration
        animation.values = values
        
        layer.add(animation, forKey: "shake")
    }
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        
        pulse.duration = 0.2
        pulse.speed = 1
        pulse.fromValue = 0.95
        pulse.toValue = 1.05
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = -1
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
}


extension UIView {
    
    public class func insertGradient(in view: UIView, hexStrings strings: (String, String)) {
        
        let colors = (UIColor.init(hexString: strings.0).cgColor, UIColor.init(hexString: strings.1).cgColor)
        let gLayer = CAGradientLayer().createGradientLayer(withColors: colors)
        
        gLayer.frame = view.frame
        view.layer.insertSublayer(gLayer, at: 0)
    }
    
    public func apply(borderColor color: UIColor = .white, borderWidth width: CGFloat = 0, andRadius radius: CGFloat?) {
        
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        
        guard let radius = radius else {
            self.layer.cornerRadius = self.frame.size.height / 2
            return
        }
        self.layer.cornerRadius = radius
    }
}

extension DateFormatter {
    
    public func convertToString(dates: [Date]) -> [String] {
        
        self.dateFormat = "dd/MM/yyyy"
        var stringDates = [String]()
        for date in dates {
            let strDate = self.string(from: date)
            stringDates.append(strDate)
        }
        return stringDates
    }
    
    class public func convertDateInString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd/MM/yy"
        return dateFormatter.string(from: date)
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}


extension UILabel {
    
    public func attributed(strings: [String], colors: [UIColor]?, fonts:[UIFont]) {
        
        var attributes = [NSAttributedStringKey : NSObject]()
        let attrStr = NSMutableAttributedString (string: "", attributes: attributes)
        
        strings.enumerated().forEach { (index, str) in
            if colors == nil {
                
                attributes = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : UIColor.white]
            } else {
                
                attributes = [NSAttributedStringKey.font : fonts[index], NSAttributedStringKey.foregroundColor : colors![index]]
            }
            let newStr = NSMutableAttributedString(string: str, attributes: attributes)
            attrStr.append(newStr)
            
            }
        self.attributedText = attrStr
        
    }
    
    class public func applyLabelsColors(_ arguments: [(UILabel, UIColor)]) {
        
        arguments.forEach { $0.0.textColor = $0.1 }
    }
}

extension Collection where Index == Int {
    
    func randomElement() -> Iterator.Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
    
}

