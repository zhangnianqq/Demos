//
//  ViewController.swift
//  RunTime
//
//  Created by zhangnian on 16/9/21.
//  Copyright © 2016年 zhangnian. All rights reserved.
/*
 swift runtime  参考链接：http://www.jianshu.com/p/9c36a5b7820a
 */

import UIKit

class TestSwiftClass {
    var sex:Bool = true
    var age:Int = 22
    var name:String = "Dylan"
    var cars:AnyObject! = nil
    
    func sayHello(name:String)  {
        print("F\(#function),L\(#line)")
    }
}

class ViewController: UIViewController {
    var sex:Bool = true
    var age:Int = 22
    var name:String = "Dylan"
    var cars:AnyObject! = nil
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //没有继承自NSObject的类时不做运行时方法的
//        getMethodAndPropertiseFromClass(cls: TestSwiftClass.self)
        //继承NSObject 的类 走运行时机制
//        getMethodAndPropertiseFromClass(cls: ViewController.self)
        swizzleMethod(cls: ViewController.self, originMethod: #selector(ViewController.viewDidAppear(_:)), destinationMethod: #selector(ViewController.my_viewDidAppear(_:)))
        swizzleMethod(cls: ViewController.self, originMethod: #selector(ViewController.returnInt(value:)), destinationMethod: #selector(ViewController.my_returnInt(value:)))
        
        print("\(returnInt(value: 12))")

    }
    
    //viewDidAppear 可以直接替换掉  体统方法隐含着已经有了@objc 标示 所以可以动态调用
    //原来系统方法
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("原来方法")
    }
    //自己写的替换方法
    func my_viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        print("替换方法")
    }
    
    
    //自定义方法默认没有包含@objc标示 不会动态调用 如果想动态调用 需要添加关键字dynamic 在编译时会为方法添加@objc 标示 使其动态调用
    dynamic func returnInt(value:Int) -> Int {
        print("原来方法")
        return 10
    }
    
    func my_returnInt(value:Int) -> Int {
        print("替换方法")
        return 11
    }
    
    //函数返回值为 元祖类型  此种方法在runtime时 获得不到 因为object——c 不支持元祖类型 元祖是swift的语法
    func returnTuple(name:String) -> (Bool,Int,String) {
        return (true,10,"dylan")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //runtime 方法
    //获取类对象的 方法 和属性
    func getMethodAndPropertiseFromClass(cls:AnyClass) {
        print("methods")
        var methodNum:UInt32 = 0;
        let methods = class_copyMethodList(cls, &methodNum);
        
        //遍历方法
        for index in 0..<numericCast(methodNum) {
            let met:Method = methods![index]!
            //方法名
            print("m_name:\(method_getName(met))")
            //类型此处的类型为 encodings 参考链接：http://nshipster.cn/type-encodings/
            print("m_retrnType:\(String(utf8String:method_copyReturnType(met)))")
            print("m_type:\(String(utf8String:method_getTypeEncoding(met)))")
        }
        
        //属性
        print("properties")
        //此处一个设想  那种模型转换赋值的是不是这样赋值的呢？
        var propNum:UInt32 = 0
        let properties = class_copyPropertyList(cls, &propNum)
        
        for index in 0..<numericCast(propNum) {
            let prop:objc_property_t = properties![index]!
            print("p_name:\(String(utf8String:property_getName(prop)))")
            print("p_attr:\(String(utf8String:property_getAttributes(prop)))")
        }
    }
    
    
    func swizzleMethod(cls:AnyClass!, originMethod:Selector, destinationMethod:Selector) {
        //class_getInstanceMethod 获取对象方法
        //class_getClassMethod  获取类方法
        
        //原来的方法
        let origin = class_getInstanceMethod(cls, originMethod)
        //替换的方法 新方法
        let swiz = class_getInstanceMethod(cls, destinationMethod)
        // 用新方法替换原来的方法
        method_exchangeImplementations(origin, swiz)
    }
    
    
}

