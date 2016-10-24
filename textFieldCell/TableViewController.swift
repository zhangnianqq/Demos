///
//  TableViewController.swift
//  CellDemo
//
//  Created by zhangnian on 2016/10/17.
//  Copyright © 2016年 zhangnian. All rights reserved.
// 文本处理 Cell Demo 

import UIKit

class TableViewController: UITableViewController,InputTableViewCellDelegate,HCountdownButtonDelegate {
    var dataSoures = [InputModel]()
    @IBOutlet var OKButton: UIButton!
    
    //图片校验码+计时器所需控件
    var imgButton:UIButton?
    var timeLabel:UILabel?
    //图片计时按钮
    var countDownBtn:HCountdownButton?
    var running:Bool = false                //判断时间是不是正在倒计时中
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OKButton.frame = CGRect(x: 20, y: 20, width: kScreen_Width-40, height: 44)
        OKButton.layer.cornerRadius = 4
        OKButton.layer.masksToBounds = true
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreen_Width, height: 64))
        footerView.addSubview(OKButton)
        self.tableView.tableFooterView = footerView
        let icons = ["userid","code_ico","smscode_ico","myinfo_id","myinfo_report","myinfo_time"]
        let events = ["cell.type.phone","cell.type.imgcode","cell.type.msgcode","cell.type.id","cell.type.report.no","cell.type.date","cell.type.version"]
        var placeHolders = ["请输入您的手机号","请输入图形验证码","请输入短信验证码"]
        let titles = ["身份证号","报告编号","报告时间","当前版本"]

        for i in 0..<events.count {
            let model = InputModel()
            if i < icons.count {
                model.iconName = icons[i]
            }
            if i >= 3 {
                model.title = titles[i-3]
            }
            model.textColor = UIColor.black
            if i < placeHolders.count {
                model.placeHolder = placeHolders[i]
            }
            model.inputAlignment = NSTextAlignment.left
            if i < 3 {
                model.keyboardType = UIKeyboardType.numberPad
            }else {
                model.keyboardType = UIKeyboardType.numbersAndPunctuation
            }
            if i == 5 || i == 6 {
                model.clickEnable = true
            }else{
                model.clickEnable = false
            }
            model.secureTextEntry = false
            model.lineFrame = CGRect(x: 15, y: 43.5, width: kScreen_Width-30, height: 0.5)
            model.event = events[i]
            if i == 5 {
                model.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }else{
                model.accessoryType = UITableViewCellAccessoryType.none
            }
            //右边带图形按钮的
            if i == 1 {
                model.accessoryView = self.accessoryViewWithImageButton()
            }else if i == 2 {
                model.accessoryView = self.accessoryViewWithCountButton()
            }else if i == 3 {
                model.accessoryView = self.accessoryViewWithImageAndCountButton()
            }
            dataSoures.append(model)
        }
    }
    
    //计时器按钮
    func accessoryViewWithCountButton() -> UIView {
        let button = HCountdownButton()
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 50)
        button.disabledTitleColor = UIColor.colorWithRGB(rgb: "rgb(153, 153, 153)")
        button.identifyKey = "PBOCRegisterAction"
        button.timeInterval = 60
        button.setTitleColor(UIColor.colorWithRGB(rgb: "rgb(13, 71, 115)"), for: UIControlState.normal)
        button.setTitle("获取验证码", for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.addTarget(self, action: #selector(TableViewController.fire(sender:)), for: UIControlEvents.touchUpInside)
        button.delegate = self
        
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: 0.5, height: button.height)
        line.backgroundColor = UIColor(white: 0.8, alpha: 0.8).cgColor
        button.layer.addSublayer(line)
        
        return button;
    }
    
    
    /// 获取校验码
    func fire(sender:HCountdownButton) {
        print("获取校验码")
        sender.fire()
    }
  
    
    
    //MARK: - 图片按钮+计时器
    func accessoryViewWithImageAndCountButton() -> UIView {
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
        self.countDownBtn = HCountdownButton()
        self.countDownBtn?.frame = CGRect.zero
        self.countDownBtn?.identifyKey = "PBOCRefreshImgCode1"
        self.countDownBtn?.timeInterval = 30
        self.countDownBtn?.delegate = self
        tmpView.addSubview(self.countDownBtn!)
        
        
        self.imgButton = UIButton(type: UIButtonType.custom)
        self.imgButton?.frame = CGRect(x: 0, y: 0, width: tmpView.width-20, height: tmpView.height)
        self.imgButton?.backgroundColor = UIColor.cyan
        self.imgButton?.addTarget(self, action: #selector(TableViewController.countButtonGetImageCode(sender:)), for: UIControlEvents.touchUpInside)
        tmpView.addSubview(self.imgButton!)
    
        self.timeLabel = UILabel(frame: CGRect(x: self.imgButton!.right, y: 0, width: 0, height: tmpView.height))
        self.timeLabel?.font = UIFont.systemFont(ofSize: 15)
        self.timeLabel?.textColor = UIColor.colorWithRGB(rgb: "rgb(102, 102, 102)")
        self.timeLabel?.textAlignment = NSTextAlignment.center;
        tmpView.addSubview(self.timeLabel!)
        
        return tmpView;
    }

    //图片按钮点击
    func countButtonGetImageCode(sender:UIButton) {
        self.view.endEditing(true) //收键盘
        
        if self.running {
            print("操作频繁提示")
            return
        }
        sender.backgroundColor = UIColor.randomColor()
        self.countDownBtn?.fire()
        UIView.animate(withDuration: 0.25) { 
            self.imgButton?.frame = CGRect(x: 0, y: 0, width: 90, height: 44)
            self.timeLabel?.frame = CGRect(x: self.imgButton!.right, y: 0, width: 120-90, height: 44)
        }
    }
    
    //MARK: - HCountdownButtonDelegate
    func fireFinished(_ countdownButton: HCountdownButton!) {
        if countDownBtn?.identifyKey == "PBOCRefreshImgCode1" {
            self.running = false
            UIView.animate(withDuration: 0.25, animations: {
                self.imgButton?.frame = CGRect(x: 10, y: 0, width: 100, height: 44)
                self.timeLabel?.frame = CGRect(x: self.imgButton!.right, y: 0, width: 0, height: 44)
            })
            return
        }
        countdownButton.setTitle("重新获取验证码", for: UIControlState.normal)
    }
    
    func countingDown(_ countdownButton: HCountdownButton!, leftTimeInterval: TimeInterval) {
        if countDownBtn?.identifyKey == "PBOCRefreshImgCode1" {
            self.running         = true;
            self.imgButton?.frame = CGRect(x: 0, y: 0, width: 90, height: 44)
            
            self.timeLabel?.frame = CGRect(x: self.imgButton!.right, y: 0, width: 120-90, height: 44)
    
            self.timeLabel?.text  = String(format: "%.fs", leftTimeInterval)
        }
    }
    
    //MARK: - 图片按钮获取
    // 添加一个颜色变换button
    func accessoryViewWithImageButton() -> UIView {
        let tmpView = UIView  (frame:CGRect(x:0, y:0, width:120, height:44));
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: view.width-10, height: tmpView.height)
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action: #selector(TableViewController.getImageCode(sender:)), for: UIControlEvents.touchUpInside)
        tmpView.addSubview(button)
        return tmpView
    }
    
    func getImageCode(sender:UIButton) {
        print("获取图片校验码")
        sender.backgroundColor = UIColor.randomColor()
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSoures.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as? InputTableViewCell
        if cell == nil {
            cell = InputTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "textFieldCell")
            cell?.delegate = self
        }
        cell?.setObject(dataSoures[indexPath.row])
        
        return cell!
    }
    // MARK: - InputTableViewCellDelegate
    //输入框变换时触发
    func inputTableViewCell(_ cell: InputTableViewCell!, textFieldEditingChanged value: String!) {
        //根据标示判断
        if cell.event == "cell.type.phone" {
            
        }
    }
    //将要变化时根据输入格式是否正确 返回是否把对应字符加入输入框内
    func inputTableViewCell(_ cell: InputTableViewCell!, textFieldShouldChangeCharactersIn range: NSRange, replacementString string: String!) -> Bool {
        var result = true
        if cell.event == "cell.type.phone" {
            result = cell.inputLimitLength(11, allow: kAllowNumbers, inputCharacter: string)
        }
        return result
    }
    
    func inputTableViewCell(_ cell: InputTableViewCell!, didSelectEvent event: String!) {
        if cell.event == "cell.type.date" {
            print("点击了时间Cell")
        }else{
            print("点击了Cell")
        }
    }
    
    
    @IBAction func OKButtonClick(_ sender: UIButton) {
        for model in dataSoures {
            print("\(model.text)\n")
        }
    }
}
