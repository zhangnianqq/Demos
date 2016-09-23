//
//  ViewController.swift
//  Storyboard手势
//
//  Created by zhangnian on 16/9/23.
//  Copyright © 2016年 zhangnian. All rights reserved.
/*参考资料：  https://lvwenhan.com/ios/453.html */

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var middleViewTopSpaceLayout: NSLayoutConstraint!
    
    @IBOutlet var pagGesture: UIPanGestureRecognizer!
    
    var middleViewTopSpaceLayoutConstant:CGFloat!
    var middleViewOriginY:CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //添加手势触发
        pagGesture.addTarget(self, action: #selector(ViewController.pan))
    
        middleViewTopSpaceLayoutConstant = middleViewTopSpaceLayout.constant
        middleViewOriginY = middleView.frame.origin.y
        
        //手动载入xib
        let button = Bundle.main.loadNibNamed("CustomButton", owner: self, options: nil)?.first as! UIButton
        button.center = view.center
        button.layer.cornerRadius = 10
        view.addSubview(button)
    }
    
    func pan() {
        if pagGesture.state == UIGestureRecognizerState.ended {
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.middleView.frame.origin.y = self.middleViewOriginY
                }, completion: { (success:Bool) in
                    if success {
                        self.middleViewTopSpaceLayout.constant = self.middleViewTopSpaceLayoutConstant
                    }
            })
            return
        }
        let y = pagGesture.translation(in: self.view).y
        middleViewTopSpaceLayout.constant = middleViewTopSpaceLayoutConstant+y
    }

    @IBAction func centerButtonBeTapped(sender:UIButton) {
        print("不要嘛")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

