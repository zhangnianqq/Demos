//
//  SubViewController.swift
//  Test
//
//  Created by zhangnian on 16/9/18.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

class SubViewController: UIViewController {
    
    var data:String?
    
    @IBOutlet weak var JumpBackButton: UIButton!
    @IBOutlet weak var outTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        outTextField.text = data
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue的标示
        if segue.identifier == "subPopMain" {
            //此处触发里按钮点击的 sub->main 所以 segue.source是sub  segue.destination是main
            //在此处可以填写button触发里需要处理的问题
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
