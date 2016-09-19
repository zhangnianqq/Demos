//
//  ViewController.swift
//  Test
//
//  Created by zhangnian on 16/9/18.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var jumpButton: UIButton!
    
    @IBOutlet weak var inputTextField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup aft
        
    }

    
    /*正向传值 main -> sub
     直接在button上拖拽的segue指向sub 会触发该方法
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //判断segue的标识 根据标示 判断是跳转到那个类
        if segue.identifier == "MainPushSub" {
            //此处获取segue要跳转的控制器
            let send = segue.destination as? SubViewController
            //此处传值
            send?.data = inputTextField.text
        }
    }
    
    
    /*反向传值：sub -> Main
     步骤：1、在Main类添加方法@IBAction func close(segue: UIStoryboardSegue){}  
     (注意：此方法没有提示 需要手动去敲)
     2、在storyboard的sub视图中，点击按钮+control，拖拽至Exit,选择弹出方法例closeWithSegue:
     
     以上操作做完，点击按钮时会触发该方法
     */
    @IBAction func close(segue: UIStoryboardSegue) {
        //判断segue的标识 根据标示 判断是跳转到那个类
        if segue.identifier == "subPopMain" {
            //segue.source 是获取返回的sub控制器
            //segue.destination 是获取main控制器
            let subVC = segue.source as? SubViewController
            self.inputTextField.text = subVC?.outTextField.text
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

