//
//  DateExtension.swift
//  类扩展
//
//  Created by zhangnian on 15/11/19.
//  Copyright © 2015年 zhangnian. All rights reserved.
//

import UIKit

extension Date{
    /*
    //当前时间加上1天
    let date : Date = Date().dateByAddingTimeInterval(60 * 60 * 24)
    */
    /**
    对象时间和输入时间的天数差
    用法：date.daysInBetweenDate(Date())
    - parameter date: 时间
    
    - returns: 天数
    */
    func daysInBetweenDate(date: Date) -> Int
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff/86400)
        // roundoff() 方法作用是  douuble类型 四舍五入转整形
        return diff.roundoff()
    }
    
    /**
     对象时间和输入时间的小时差
     用法：date.hoursInBetweenDate(Date())
     - parameter date: 时间
     
     - returns: 小时数
     */
    func hoursInBetweenDate(date: Date) -> Int
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff/3600)
        return diff.roundoff()
    }
    /**
     对象时间和输入时间的分钟差
     用法：date.minutesInBetweenDate(Date())
     - parameter date: 时间
     
     - returns: 分数
     */
    func minutesInBetweenDate(date: Date) -> Int
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff/60)
        return diff.roundoff()
    }
    /**
     对象时间和输入时间的秒差
     用法：date.secondsInBetweenDate(Date())
     - parameter date: 时间
     
     - returns: 分数
     */
    func secondsInBetweenDate(date: Date) -> Int
    {
        var diff = self.timeIntervalSinceNow - date.timeIntervalSinceNow
        diff = fabs(diff)
        return diff.roundoff()
    }
    
    /**
     //时间转时间戳 用法 Date().dateToDouble()
     
     - returns: 当前时区的时间戳
     */
    func dateToString()->String{
        return "\(Int(self.timeIntervalSince1970))"
    }
    func dateToDouble()->Double{
        return Double(self.timeIntervalSince1970)
    }
    
    /**
     //时间戳转为时间 用法 Date.dateWithTimeIntervalInMilliSecondSince1970(Date().dataToDouble())
     
     - parameter timeIntervalInMilliSecond:Double类型的时间戳
     
     - returns: 时间戳转为时间
     */
    static func dateWithTimeIntervalInMilliSecondSince1970( timeIntervalInMilliSecond:Double)->NSString{
        var timeInterval:Double  = timeIntervalInMilliSecond
        if timeIntervalInMilliSecond > 140000000000 {
            timeInterval = timeIntervalInMilliSecond/1000
        }
        //加8小时 为时区转换
        let ret:Date = Date(timeIntervalSince1970: timeInterval+8*60*60)
        let timeStr:String = "\(ret)" //长度25
        let timeS:NSString = (timeStr as NSString).substring(to: timeStr.length-5) as NSString
        return timeS
    }

    
    /*
    /*
    年的显示：
    yy：年的后面2位数字
    yyyy：显示完整的年
    月的显示：
    M：显示成1~12，1位数或2位数
    MM：显示成01~12，不足2位数会补0
    MMM：英文月份的缩写，例如：Jan
    MMMM：英文月份完整显示，例如：January
    
    日的显示：
    d：显示成1~31，1位数或2位数
    dd：显示成01~31，不足2位数会补0
    星期的显示：
    EEE：星期的英文缩写，如Sun
    EEEE：星期的英文完整显示，如，Sunday
    
    上/下午的显示：
    aa：显示AM或PM
    
    小時的显示：
    H：显示成0~23，1位数或2位数(24小时制
    HH：显示成00~23，不足2位数会补0(24小时制)
    K：显示成0~12，1位数或2位数(12小時制)
    KK：显示成0~12，不足2位数会补0(12小时制)
    
    分的显示：
    m：显示0~59，1位数或2位数
    mm：显示00~59，不足2位数会补0
    
    秒的显示：
    s：显示0~59，1位数或2位数
    ss：显示00~59，不足2位数会补0
    S： 毫秒的显示
    时区的显示：
    z / zz /zzz ：PDT
    zzzz：Pacific Daylight Time
    Z / ZZ / ZZZ ：-0800
    ZZZZ：GMT -08:00
    v：PT
    vvvv：Pacific Time
    */

    */
    /**
    获取当前时间 字符串 时间格式为 例：let dataString = Date().dataChangeString(),
    let dataString = Date().dataChangeString("yyyy:MM:dd HH:mm"),
    
    - parameter dateFormat: 时间格式 可不写
    
    - returns: 时间对象
    */
    func dataChangeString(dateFormat:String = "yyyy:MM:dd HH:mm") -> String {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        let destDateString = dateFormatter.string(from: self.dateChangeBeiJingTime() as Date)
        
        return destDateString;
    }
    /**
     对象时间转为北京时间
     
     - returns: 北京时间
     */
    func dateChangeBeiJingTime() -> Date {
        //时间转为北京时间
        //源日期时间
        let sourceTimeZone = NSTimeZone(abbreviation: "UTC")
        //转换后的目标日期时区
        let destinationTimeZone = NSTimeZone(forSecondsFromGMT: 8)
        //源日期和世界标准时间的偏移量
        let sourceGMTOffset = sourceTimeZone?.secondsFromGMT(for: self as Date)
        //目标日期与本地时区的偏移量
        let destinationGMTOffset = destinationTimeZone.secondsFromGMT(for: self as Date)
        //得到时间偏移量的差值
        let interval = destinationGMTOffset - sourceGMTOffset!;
        //转为现在时间
        let destinationDateNow = Date(timeInterval: TimeInterval(interval), since: self as Date)
        return destinationDateNow
    }
    
    /**
     获取对象时间的指定格式的 时间  默认为返回北京时间的日期
     
     - parameter dateFormat: 时间格式
     
     - returns: 时间对象
     */
    func getCurrentDate(dateFormat:String = "yyyy:MM:dd") -> Date {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateStr = dateFormatter.string(from: self.dateChangeBeiJingTime() as Date)
        //格林位置时间
        let dateTest = dateFormatter.date(from: dateStr)
        if let date = dateTest {
            return date.dateChangeBeiJingTime()
        }
        NSLog("时间转化失败 返回当前时间")
        return Date()
        
    }
    
    /**
     字符串转时间
     
     - parameter dateString:  时间字符串
     - parameter dateFormat: 时间格式
     
     - returns: 时间
     */
    func stringToDate(dateString:String,dateFormat:String = "yyyy:MM:dd HH:mm:ss") -> Date {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateTest = dateFormatter.date(from: dateString)
        if dateTest == nil{
            NSLog("时间转化失败 返回当前时间")
            return Date()
        }
        return dateTest!.dateChangeBeiJingTime()
    }
    
    /**
     获取时间对象的日期
     
     - returns: 周几的字符串
     */
    func getDateWeek() -> String {
        let calendar:NSCalendar = NSCalendar.current as NSCalendar
        let flags: NSCalendar.Unit = NSCalendar.Unit.weekday
        let comps:DateComponents = calendar.components(flags, from: self)
        
//        let week = comps!.weekOfYear; // 今年的第几周
//        let Ordinal = comps?.weekOfMonth // 这个月的第几周
        if let weekday = comps.weekday {
            // 星期几（注意，周日是“1”，周一是“2”。。。。）
            switch weekday {
            case 1:
                return "周日"
            case 2:
                return "周一"
            case 3:
                return "周二"
            case 4:
                return "周三"
            case 5:
                return "周四"
            case 6:
                return "周五"
            default:
                return "周六"
            }
        }else{
            assert(true, "时间转换为周几出错")
            return "时间转换出错"
        }
    }
}
