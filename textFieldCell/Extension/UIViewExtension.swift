//
//  UIViewExtension.swift
//  DeliveryStaff
//
//  Created by 孙晨 on 16/3/21.
//  Copyright © 2016年 SunZhaoPei. All rights reserved.
//

import UIKit

extension UIView{
    
    /**
     *  实现UIView抖动效果
     */
    func shakeAnimation() -> Void {
        let layer = self.layer
        let position = layer.position
        let y = CGPoint(x:position.x - 3.0, y:position.y);
        let x = CGPoint(x:position.x + 3.0, y:position.y);
        let animation = CABasicAnimation.init(keyPath: "position")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = NSValue.init(cgPoint: x)
        animation.toValue = NSValue.init(cgPoint: y)
        animation.autoreverses = true
        animation.duration = 0.08
        animation.repeatCount = 3
        layer.add(animation, forKey: nil)
    }
    
    
    /**
     左边带图片文字,右边label
     
     - parameter frame:     frame
     - parameter text:      text
     - parameter textColor: textColor
     - parameter font:      font
     - parameter imgName:   imgName
     
     - returns: nil
     */
    class func creatLabelWithImgLab(frame:CGRect, text:String, textColor:UIColor ,font:CGFloat?,imgName:String?,title:String?)->UIView{
        let view = UIView(frame: frame)
        let img = UIImageView.createImageView(frame: CGRect(x: 0, y: 0,  width: 30, height: frame.size.height), imageName: imgName)
        view.addSubview(img)
        let labOther = UILabel(frame: CGRect.zero)
        labOther.text = title
        labOther.sizeToFit()
        
        let lab:UILabel = UILabel.createLabel(frame: CGRect(x: img.right, y: img.top, width: labOther.size.width, height: frame.size.height), text: title!, textColor: UIColor.black, font: font)
        lab.textAlignment = NSTextAlignment.left
        view.addSubview(lab)
        let labContent =  UILabel.createLabel(frame: CGRect(x: lab.right, y: img.top, width: frame.size.width-img.width-lab.width,  height: frame.size.height), text: text, textColor: textColor, font: font)
        labContent.textAlignment = NSTextAlignment.left
        view.addSubview(labContent)
        return view
    }
    /**
     左边是图片文字，右边textfield
     
     - parameter frame:     fram
     - parameter text:      lab标题
     - parameter placehold: 占位符
     - parameter font:      字号
     - parameter imgleft:   左边图片
     - parameter imgRight:  textf右边图片
     
     - returns: textf
     */
    class func creatTextfImgLab(frame:CGRect,text:String,placehold:String ,font:CGFloat?,imgleft:String?,imgRight:String?)->UIView{
        let view = UIView(frame: frame)
        let img = UIImageView.createImageView(frame: CGRect(x:0,y: 0,width: 30, height: frame.size.height), imageName: imgleft)
        view.addSubview(img)
        let labOther = UILabel(frame: CGRect.zero)
        labOther.text = text
        labOther.sizeToFit()
        let lab = UILabel.createLabel(frame: CGRect(x:img.right, y:img.top, width:labOther.width, height:frame.size.height), text: text, textColor: UIColor.black, font: font)
        lab.textAlignment = NSTextAlignment.left
        view.addSubview(lab)
        
        let textf = UITextField.createTextField(frame: CGRect(x:lab.right+10, y:img.top, width:frame.size.width-img.width-lab.width-10, height:frame.size.height), leftImageName: nil, rightImageName: imgRight, placheholder: placehold, font: 15, isPassWord: false, borderStyle: UITextBorderStyle.none, keyboardType: UIKeyboardType.default)
        textf.layer.borderWidth = 1.0
        textf.layer.borderColor = UIColor.black.cgColor
        textf.layer.cornerRadius = 5
        view.addSubview(textf)
        return view
    }
}
