//
//  ViewController.swift
//  StroyBoard+xib
//
//  Created by zhangnian on 16/9/23.
//  Copyright © 2016年 zhangnian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "FirstTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FirstTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstTableViewCell", for: indexPath) as! FirstTableViewCell
        cell.cellTitle.text = "我是标题"
        if indexPath.row % 2 == 0 {
            cell.cellSwitch.isOn = true
        }else{
            cell.cellSwitch.isOn = false
        }
        return cell
    }
}

