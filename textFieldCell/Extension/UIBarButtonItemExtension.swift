//
//  UIBarButtonItemExtension.swift
//  类扩展
//
//  Created by zhangnian on 16/3/10.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    /// 针对导航条右边按钮的自定义item
    convenience init(rightImageName: String, highlImageName: String, targer: AnyObject, action: Selector) {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: rightImageName), for: .normal)
        button.setImage(UIImage(named: highlImageName), for: .highlighted)
        button.frame = CGRect(x:0, y:0, width:50, height: 44)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        button.addTarget(targer, action: action, for: .touchUpInside)
        
        self.init(customView: button)
    }
    /// 针对导航条左边按钮的自定义item
    convenience init(leftImageName: String, highlImageName: String, targer: AnyObject, action: Selector) {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: leftImageName), for: .normal)
        button.setImage(UIImage(named: highlImageName), for: .highlighted)
        button.frame = CGRect(x:0,y:0,width:44,height:44)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        button.addTarget(targer, action: action, for: .touchUpInside)
        
        self.init(customView: button)
    }
    
    /// 针对导航条右边按钮有选中状态的自定义item
    convenience init(rightImageName: String, highlImageName: String, selectedImage: String, targer: AnyObject, action: Selector) {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: rightImageName), for: .normal)
        button.setImage(UIImage(named: highlImageName), for: .highlighted)
        button.frame = CGRect(x:0, y:0, width:50, height:44)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10)
        button.setImage(UIImage(named: selectedImage), for: .selected)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        button.addTarget(targer, action: action, for: .touchUpInside)
        
        self.init(customView: button)
    }
    
    
    /// 导航条右边纯文字按钮
    convenience init(title: String, titleClocr: UIColor, targer: AnyObject ,action: Selector) {
        
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleClocr, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        button.frame = CGRect(x:0, y:0, width:80, height:44)
        button.titleLabel?.textAlignment = NSTextAlignment.right
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5)
        button.addTarget(targer, action: action, for: .touchUpInside)
        
        self.init(customView: button)
    }
    
    /// 针对导航条左边按钮的图片+文字按钮
    convenience init(leftImageName: String, highlImageName: String, title:String, targer: AnyObject, action: Selector) {
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: leftImageName), for: .normal)
        button.setImage(UIImage(named: highlImageName), for: .highlighted)
        button.setTitle(title, for: UIControlState.normal)
        button.setTitle(title, for: UIControlState.highlighted)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 18)
        let size = title.getTextRectSize(font: UIFont.systemFont(ofSize: 18), size: CGSize(width:kScreen_Width, height:20))
        button.frame = CGRect(x:0, y:0, width:size.width+44, height:44)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        button.addTarget(targer, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
    
}

