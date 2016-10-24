//
//  ViewController.swift
//  Ble
//
//  Created by ddp on 16/9/27.
//  Copyright © 2016年 DDP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         let vc = JOBTFirstViewController()
        /*
         @property(copy,nonatomic) NSString *productType;
         @property(copy,nonatomic) NSString *billCodeSub;
         @property(copy,nonatomic) NSString *destinationCenter;
         @property(copy,nonatomic) NSString *dispatchSite;
         @property(copy,nonatomic) NSString *billCode;
         @property(copy,nonatomic) NSString *count;
         @property(copy,nonatomic) NSString *receiverAddress;
         @property(copy,nonatomic) NSString *registerSite;
         @property(copy,nonatomic) NSString *sendDate;
         @property(copy,nonatomic) NSString *dispatchMode;
         */
        vc.billCode = "686000000000";
        vc.billCodeSub = ";686000000000-2;";
        vc.productType = "小货通";
        vc.destinationCenter = "福州连江点";
        vc.dispatchSite = "福州连江点";
        vc.count = "2"
        vc.receiverAddress = "浙江省/杭州市/市辖区jjjjk";
        vc.sendDate = "2016-08-20 16:01:24";
        vc.dispatchMode = "派送";
        vc.registerSite = "测试站C";
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

