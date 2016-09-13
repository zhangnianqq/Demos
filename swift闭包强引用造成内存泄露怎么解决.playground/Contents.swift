//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
/*
swift闭包强引用造成请引用造成内存泄露怎么解决？
 */
class SmartAirConditioner {
    var temperature:Int = 26
    var temperatureChange: ((Int) -> ())!
    
    init() {
        /*错误使用 内存泄露
         例：
        temperatureChange = { newTemperature in
            //abs(Int) 返回绝对值
            if abs(newTemperature - self.temperature) >= 10 {
                print("这个不符合标准")
            }else{
                self.temperature = newTemperature
                print("符合标准")
            }
        }
         */
        
        //解决：
        //此处 如果没有[unowned self](闭包捕获列表) 意为闭包中self是若引用 self对象肯定存在
        /*方法一：
        temperatureChange = {  [unowned self] newTemperature in
            //abs(Int) 返回绝对值
            if abs(newTemperature - self.temperature) >= 10 {
                print("这个不符合标准")
            }else{
                self.temperature = newTemperature
                print("符合标准")
            }
        }
         */
        //方法二: 此处使用weak  意为弱引用 self对象可能不存在 所以需要判断self 不为nil
        temperatureChange = {  [weak self] newTemperature in
            if let weakself = self {
                //abs(Int) 返回绝对值
                if abs(newTemperature - weakself.temperature) >= 10 {
                    print("这个不符合标准")
                }else{
                    weakself.temperature = newTemperature
                    print("符合标准")
                }
            }
        }
    }
    deinit {
        print("内存释放")
    }
}
var smartair:SmartAirConditioner? = SmartAirConditioner()
smartair?.temperature
smartair?.temperatureChange(25)
smartair = nil