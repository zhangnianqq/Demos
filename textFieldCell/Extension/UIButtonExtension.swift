//
//  UIButtonExtension.swift
//  类扩展
//
//  Created by zhangnian on 16/3/10.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

extension UIButton {
    
    /**
     纯文字按钮
     
     - parameter frame: 范围
     - parameter title:  文字
     - parameter titeleColol: 文字颜色
     - parameter backgroundColor: 背景颜色
     - parameter target: 对象
     - parameter action: 触发事件
     
     - returns: 对象
     */
    class func createTitleButton(frame:CGRect,title:String?,titeleColol:UIColor?, backgroundColor:UIColor?, target:AnyObject?, action:Selector?)->UIButton {
        let button:UIButton = UIButton(type: UIButtonType.custom)
        button.configButton(frame: frame, title: title, titeleColol: titeleColol, imageName: nil, selectImageName: nil, bgImageName: nil, backgroundColor: backgroundColor, target: target, action: action)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 4
        return button
    }
    /**
     创建左图右文字的按钮
     
     - parameter frame:     范围
     - parameter imageName: 图片名称
     - parameter target:    对像
     - parameter action:    触发事件
     - parameter title:     文字
     
     - returns: 按钮对象
     */
    class func createButton(frame:CGRect, leftTitle:String?,rightImageName:String?, target:AnyObject, action:Selector ,titeleColol:UIColor?)->UIButton {
        return self.createButton(frame: frame,  title: leftTitle, imageName: rightImageName, selectImageName: nil, target: target, action: action, backgroundImageName: nil,titeleColol:titeleColol )
    }
    /**
      创建上面图片下面文字按钮
     
     - parameter frame:     范围
     - parameter topImageName: 图片名称
     - parameter target:    对像
     - parameter action:    触发事件
     - parameter botttomTitle: 文字
     - returns: 按钮对象
     */
    class func creatTopImgBottomLab(frame:CGRect, botttomTitle:String?,topImageName:String?, target:AnyObject, action:Selector ,titeleColol:UIColor?)->UIButton{
         let btn:UIButton = self.createButton(frame: frame,  title: botttomTitle, imageName: topImageName, selectImageName: nil, target: target, action: action, backgroundImageName: nil,titeleColol:titeleColol )
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0)
        btn.titleEdgeInsets = UIEdgeInsetsMake( btn.imageView!.height,0, 0, 0)
        return btn
    }
    /**
     带选择图片的按钮
     
     - parameter frame: 范围
     - parameter imageName:  图片名
     - parameter selectImageName: 选择时图片名称
     - parameter target:  对象
     - parameter action: 触发事件
     - parameter title: 文字
     - parameter backgroundImageName: 背景图
     
     - returns: 对象
     */
    class func createButton(frame:CGRect,title:String?,imageName:String?, selectImageName:String?, target:AnyObject, action:Selector,  backgroundImageName:String?,titeleColol:UIColor?)->UIButton {
        let button:UIButton = UIButton(type: UIButtonType.custom)
        button.configButton(frame: frame, title: title, titeleColol: titeleColol, imageName: imageName, selectImageName: selectImageName, bgImageName: backgroundImageName, backgroundColor: nil, target: target, action: action)
        return button
    }
    
    
    /**
     创建圆形图片按钮
     
     - parameter frame:  大小
     - parameter image:  图片
     - parameter target: 对象
     - parameter action: 触发事件
     
     - returns: 对象
     */
    class func createRoundImageButton(frame:CGRect, title:String?, titleColor:UIColor?, backgroundColor:UIColor?, bgImageName:String?,target:AnyObject?, action:Selector?) ->UIButton {
        let button:UIButton = UIButton(type: UIButtonType.custom)
        if let name = bgImageName  {
            button .setBackgroundImage(UIImage(named: name), for: UIControlState.normal)
        }
        button.configButton(frame: frame, title: title, titeleColol: titleColor, imageName: nil, selectImageName: nil, bgImageName: nil, backgroundColor: backgroundColor, target: target, action: action)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = frame.width/2
        return button
    }
    ///只有背景图的按钮
    class func createBgImageBtn(frame:CGRect ,bgImageName:String?,target:AnyObject?, action:Selector?)-> UIButton {
        let btn = UIButton( type: UIButtonType.custom)
        btn.frame = frame
        if target != nil && action != nil {
            btn.addTarget(target!, action: action!, for: UIControlEvents.touchUpInside)
        }
        if let name = bgImageName {
            btn.setBackgroundImage(UIImage(named: name), for: UIControlState.normal)
            btn.setBackgroundImage(UIImage(named: name), for: UIControlState.selected)
        }
        return btn
    }
    
    /**
     配置按钮属性
     
     - parameter frame:           范围
     - parameter title:           文字
     - parameter titeleColol:     文字颜色
     - parameter imageName:       图片名称
     - parameter selectImageName: 选择的图片名称
     - parameter bgImageName:     背景图
     - parameter backgroundColor: 背景色
     - parameter target:          对象
     - parameter action:          触发事件
     */
    func configButton(frame:CGRect,title:String?,titeleColol:UIColor?,imageName:String?, selectImageName:String?,bgImageName:String?, backgroundColor:UIColor?, target:AnyObject?, action:Selector?) {
        self.frame = frame
        if let text = title {
            self.setTitle(text, for: UIControlState.normal)
        }
        if let color = titeleColol {
            self.setTitleColor(color, for: UIControlState.normal)
        }
        if let name = imageName  {
            self.setImage(UIImage(named: name), for: UIControlState.normal)
        }
        if let name = selectImageName {
            self.setImage(UIImage(named: name), for: UIControlState.selected)
        }
        if let color = backgroundColor {
            self.backgroundColor = color
        }
        if let name = bgImageName {
            self.setBackgroundImage(UIImage(named: name), for: UIControlState.normal)
            self.setBackgroundImage(UIImage(named: name), for: UIControlState.selected)
        }
        if target != nil && action != nil {
            self.addTarget(target!, action: action!, for: UIControlEvents.touchUpInside)
        }
    }
}
