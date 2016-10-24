//
//  StringExtension.swift
//  类扩展
//
//  Created by zhangnian on 15/11/18.
//  Copyright © 2015年 zhangnian. All rights reserved.
//

import UIKit
import CoreLocation

/** 限制输入，只能为数字 */
let kAllowNumbers:String = "0123456789\n"
/** 限制输入，只能为字母、数字 */
let kAllowAlphanum:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\n"

extension String{
    /// 字符串长度
    var length:Int {return self.characters.count}
    /// string转为NSString
    var OCString: NSString {
        get {
            return self as NSString
        }
    }
    
    
    /// string转为Float
    var floatValue: Float? {return NumberFormatter().number(from: self)?.floatValue}
    /// string转为Double
    var doubleValue: Double? {return NumberFormatter().number(from: self)?.doubleValue}
    
    
    /**
     修剪在头部和尾部空白字符 （空格和换行）。
     
     - returns: 字符串
     */
    func stringByTrim() -> String {
        let set:CharacterSet = NSCharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: set)
    }
    
    /**
     *  判断字符串是否为空
     *
     *  @return 判断值
     */
    static func isBlankString(string:String?) -> Bool {
        //删除所有的空格
        guard let str = string else {
            return true
        }
        let set:CharacterSet = NSCharacterSet.whitespaces
        if str.trimmingCharacters(in: set).length == 0 {
          return true
        }
        return false
    }
    
    /**
     字符串截取 从第几位开始 长度为几位的字符串
     
     - parameter start:  开始位置
     - parameter length: 长度
     
     - returns: 字符串对象
     */
    func sub(start: Int, length: Int) -> String {
        assert(start >= 0)
        assert(length >= 0)
        assert(start <= self.characters.count - 1)
        assert(start + length <= self.characters.count)
        let a = (self as NSString).substring(from: start)
        let b = (a as NSString).substring(to: length)
        return b
    }
    /**
     获取字符串的高度和宽度
     
     - parameter font: 字体大小
     - parameter size: 最大宽高
     - returns: 字符串宽高
     */
    func getTextRectSize(font:UIFont,size:CGSize) -> CGSize {
        let attributes = [NSFontAttributeName: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = self.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect.size;
    }
    
    /**
     是否包含字符串 区分大小写
     
     - parameter s: 字符串
     
     - returns: 是否包含
     */
    func containsString(s:String) -> Bool
    {
        if(self.range(of: s) != nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
    /**
     是否包含字符串 根据后边的选项检索
     常用的选项
     NSStringCompareOptions.caseInsensitiveSearch 不区分大小写
     NSStringCompareOptions.LiteralSearch 精确的逐字符等效
     NSStringCompareOptions.BackwardsSearch  从源代码字符串的结尾搜索
     
     - parameter s:             字符串
     - parameter compareOption: 这些选项适用于不同的搜索/查找和比较方法
     
     
     - returns: 是否包含
     */
    func containsString(s:String, compareOption: NSString.CompareOptions) -> Bool
    {
        if((self.range(of: s, options: compareOption)) != nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /**
     反序排列
     
     - returns: 倒序的字符串
     */
    func reverse() -> String
    {
        var reverseString : String = ""
        for c in self.characters
        {
            reverseString = "\(c)" +  reverseString
        }
        return reverseString
    }
    
    /// 判断是否是邮箱
    func isValidateEmail() -> Bool {
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return self.regularCheck(regular: emailRegex)
    }
    
    /// 判断是否是手机号
    func isValidateMobile() -> Bool {
        //固定电话
        let phoneRegex: String = "(?:(\\(\\+?86\\))(0[0-9]{2,3}\\-?)?([2-9][0-9]{6,7})+(\\-[0-9]{1,4})?)|"
            + "(?:(86-?)?(0[0-9]{2,3}\\-?)?([2-9][0-9]{6,7})+(\\-[0-9]{1,4})?)"
        //手机号码
        let fixed :String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$"
        
        let phoneBool1 = self.regularCheck(regular: phoneRegex)
        let phoneBool2 = self.regularCheck(regular: fixed)
        
        if phoneBool1 || phoneBool2 {
            return true
        }else{
            return false
        }
    }
    
    //验证是否是 数字英文加下划线
    func isValidateEnglish() -> Bool {
        let deuRegex = "^[A-Za-z0-9]+$"
        return self.regularCheck(regular: deuRegex)
    }
    
    /// 判断是否是中文
    func isValidateChinese() -> Bool {
        let deuRegex: String = "^[\\u4E00-\\u9FA5]*$"
        return self.regularCheck(regular: deuRegex)
    }
    
    ///验证单个字符 是否是数字
    func charIsNum() -> Bool {
        let deuRegex = "[0-9]"
        return self.regularCheck(regular: deuRegex)
    }
    
    ///验证是否为小数
    func isDecimal() -> Bool {
        let deuRegex = "/^(\\-|\\+)?\\d*\\.\\d+|\\d+\\.\\d*|[1-9]\\d*$/"
        return self.regularCheck(regular: deuRegex)
    }
    
    /**
     //精确的身份证号码有效性检测
     
     - returns: 是否
     */
    mutating func isCardID() -> Bool {
        self = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        let length:NSInteger = self.length
        if length == 0 {
            return false
        }else if (length != 15 && length != 18) {
            return false
        }
        // 省份代码
        let areasArray:[String] = ["11","12", "13","14", "15","21", "22","23", "31","32", "33","34", "35","36", "37","41", "42","43", "44","45", "46","50", "51","52", "53","54", "61","62", "63","64", "65","71", "81","82", "91"]
        
        let valueStart2 = self.sub(start: 0, length: 2)
        var areaFlag:Bool = false
        for areaCode in areasArray {
            if areaCode == valueStart2 {
                areaFlag = true
                break;
            }
        }
        
        if !areaFlag {
            return false
        }
        
        
        var regularExpression:NSRegularExpression?
        var numberofMatch:Int?
        
        var year:Int = 0
        switch (length) {
        case 15:
            if let yearTemp = Int(self.sub(start: 6, length: 2)) {
                year = yearTemp+1900
            }else{
                return false
            }
            if (year % 4 == 0 || (year % 100 == 0 && year % 4 == 0)) {
                //测试出生日期的合法性
                do {
                    regularExpression = try NSRegularExpression(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive)
                }catch{
                    assert(true, "15位身份证测试出生日期正则异常")
                    return false
                }
            }else {
                //测试出生日期的合法性
                do {
                    regularExpression = try NSRegularExpression(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive)
                }catch{
                    assert(true, "15位身份证测试出生日期正则异常")
                    return false
                }
            }
            numberofMatch = regularExpression!.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, length))
            if(numberofMatch! > 0) {
                return true
            }else {
                return false
            }
        case 18:
            if let yearTemp = Int(self.sub(start: 6, length: 4)) {
                year = yearTemp
            }else{
                return false
            }
            if (year % 4 == 0 || (year % 100 == 0 && year % 4 == 0)) {
                do {
                    regularExpression = try NSRegularExpression(pattern: "^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$", options: NSRegularExpression.Options.caseInsensitive)
                }catch{
                    assert(true, "18位身份证测试出生日期正则异常")
                    return false
                }
            }else {
                do {
                    regularExpression = try NSRegularExpression(pattern: "^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$", options: NSRegularExpression.Options.caseInsensitive)
                }catch{
                    assert(true, "18位身份证测试出生日期正则异常")
                    return false
                }
            }
            numberofMatch = regularExpression!.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, length))
    
            if(numberofMatch! > 0) {
                if self.sub(start: 0, length: 16).isAllDigit() == false {
                    return false
                }
                let S = (Int(self.sub(start: 0, length: 1))!+Int(self.sub(start: 10, length: 1))!)*7+(Int(self.sub(start: 1, length: 1))!+Int(self.sub(start: 11, length: 1))!)*9+(Int(self.sub(start: 2, length: 1))!+Int(self.sub(start: 12, length: 1))!)*10+(Int(self.sub(start: 3, length: 1))!+Int(self.sub(start: 13, length: 1))!)*5+(Int(self.sub(start: 4, length: 1))!+Int(self.sub(start: 14, length: 1))!)*8+(Int(self.sub(start: 5, length: 1))!+Int(self.sub(start: 15, length: 1))!)*4+(Int(self.sub(start: 6, length: 1))!+Int(self.sub(start: 16, length: 1))!)*2+Int(self.sub(start: 7, length: 1))!*1+Int(self.sub(start: 8, length: 1))!*6+Int(self.sub(start: 9, length: 1))!*3
                let Y:Int = S % 11;
                var M = "F"
                let JYM:String = "10X98765432"
                //判断校验位
                M = JYM.sub(start: Y, length: 1)
                let test = self.sub(start: 17, length: 1)
                if M.lowercased() == test.lowercased() {
                    return true // 检测ID的校验位
                }else{
                    return false
                }
            }else {
                return false;
            }
        default:
            return false;
        }
    }
    
    
    /**
     校验正则表达式
     
     - parameter regular: 正则字符串
     
     - returns: 是否满足正则
     */
    func regularCheck(regular:String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regular).evaluate(with: self)
    }
    
    /**
     全部为数字  不能包含小数点
     
     - returns: 是否全部为数字
     */
    func isAllDigit() -> Bool {
        for uni in unicodeScalars{
            if NSCharacterSet.decimalDigits.hasMember(inPlane: UInt8(uni.value)){
                continue
            }
            return false
        }
        return true
    }
    
    //判断是否为数字 或者小数
    func isNumber() -> Bool {
        if self.isAllDigit() == true || self.isDecimal() {
            return true
        }else{
            return false
        }
    }
    
    //字符串中数字转为*
    func stringIntoDigitalSignal() -> String {
        var newStr = ""
        for i in 0..<self.length {
            let s = (self as NSString).substring(with: NSMakeRange(i, 1))
            var newS = s
            if s.charIsNum() {
                newS = "*"
            }
            newStr += newS
        }
        return newStr
    }
    
    /**
     手机号中间隐藏 例18321317202变为183****7202 只显示前三位和后4位 中间用***代替
     - returns: 隐藏中间后的手机号
     */
    func phoneCenterHide() -> String {
        if self.length <= 3 {
            return self
        }
        let footerStr = (self as NSString).substring(from: self.length-4)
        let headerStr = (self as NSString).substring(to: 3)
        let phoneStr = "\(headerStr)****\(footerStr)"
        return phoneStr
    }

    
    /// 将字符串转换成经纬度
    func stringToCLLocationCoordinate2D(separator: String) -> CLLocationCoordinate2D? {
        let arr = self.components(separatedBy: separator)
        if arr.count != 2 {
            return nil
        }
        
        let latitude: Double = NSString(string: arr[1]).doubleValue
        let longitude: Double = NSString(string: arr[0]).doubleValue
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    //小数位数过长 截取后两位
    func stringXiaoShuLiangWei() -> String {
        var str = ""
        if ((self as NSString).range(of: ".").location != NSNotFound) {
            let arr =  self.components(separatedBy: ".")
            let strLast = arr.last
            if (strLast!.length >= 3) {
                let str1 = (strLast! as NSString).substring(to: 2)
                let num:Int = Int(str1)!+1
                str = "\(arr.first!).\(num)"
            }else{
                str = self
            }
        }else{
            str = self
        }
        return str
    }
    
    /**
     距离转换 <1千米 显示米 >1千米转为千米 小数位显示1位  整数的话 不显示小数位u
     
     - parameter distance: 距离
     
     - returns: 文字
     */
    static func distanceConversion(distance:Double) -> String {
        let s = String(format:"%0.0f",distance)
        var str = "\(s)米"
        if distance > 1000 {
            let dis = String(format:"%0.1f",distance/Double(1000))
            let di = String(format:"%0.0f",distance/Double(1000))
            if di.floatValue! - dis.floatValue! == 0 {
                str = "\(di)公里"
            }else{
                str = "\(dis)公里"
            }
        }
        return str
    }
    
    //校验是否为空 中间添加符号合并
    /**
     字符串拼接  校验字符串是否有空字符串 有 忽略  两个不为空的字符串中间添加间隔字符串
     
     - parameter strArr:      字符串数组
     - parameter intervalStr: 间隔字符串
     
     - returns: 字符串对象
     */
    static func stringConcatenation(strArr:[String],intervalStr:String) -> String {
        var appedString = ""
        for i in 0..<strArr.count {
            if !appedString.hasSuffix(intervalStr) && appedString.length != 0{
                appedString += intervalStr
            }
            if strArr[i] != "" {
                appedString += strArr[i]
            }
        }
        return appedString
    }
}
extension NSString {
    /**
     *  判断字符串是否为空
     *
     *  @return 判断值
     */
    static func isBlankString(string:String?) -> Bool {
        guard let str = string else {
            return true
        }
        //删除所有的空格
        let set:CharacterSet = NSCharacterSet.whitespaces
        if str.trimmingCharacters(in: set).length == 0 {
            return true
        }
        return false
    }
}
