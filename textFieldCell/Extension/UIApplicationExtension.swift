//
//  UIApplicationExtension.swift
//  TEST
//
//  Created by zhangnian on 16/4/28.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

//屏幕宽高
public let kScreen_Width = UIScreen.main.bounds.width
public let kScreen_Height = UIScreen.main.bounds.height
public let kScreen_Bounds: CGRect = UIScreen.main.bounds
//以6为基础 等比宽高
func fixedHeight(height:CGFloat)->CGFloat{
    return  height/(667/kScreen_Height)
}

func fixedWidth(width:CGFloat) -> CGFloat {
    return width/(375/kScreen_Width)
}

extension UIApplication {
//MARK: - 沙盒路径或者Url
    func getDocumentsURL() -> NSURL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as NSURL
    }
    
    func getDocumentsPath() ->String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }
    
    func getCachesURL() -> NSURL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as NSURL
    }
    
    func getCachesPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }
    
    func getLibraryURL() -> NSURL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as NSURL
    }
    
    func getLibraryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }
//MARK: 获取项目基本信息
    /**
     获取包名 即程序名
     
     - returns: 字符串
     */
    func getAppBundleName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    //／获取中文名称
    func getAppBundleDisplayName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    /**
     获取程序bundleId
     
     - returns: 字符串
     */
    func getAppBundleID() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    }
    /**
     程序的版本 例1.2.0
     
     - returns: 字符串
     */
    func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    /**
     程序的版本号 例123
     
     - returns: 字符串
     */
    func getAppBuildVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
