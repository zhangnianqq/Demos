//
//  ViewController.swift
//  QQKuangjia
//
//  Created by ddp on 16/9/29.
//  Copyright © 2016年 DDP. All rights reserved.
//

import UIKit
//侧边栏滑动样式
enum SideSlipStyle:NSInteger {
    case None           //平移
    case Narrow         //主视图缩小
}

class ViewController: UIViewController {
    //主视图
    var homeViewController:HomeViewController = {
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return homeVC
    }()
    
    var distance:CGFloat = 0                    //距离
    //常量
    let kFullDistance:CGFloat = 0.78            //完整距离
    var kProportion:CGFloat = 1              //比例
    //侧边栏滑动样式 滑动样式设置 默认为 平移
    var sideSlipStyle:SideSlipStyle = SideSlipStyle.None {
        willSet {
            if newValue == SideSlipStyle.None {
                kProportion = 1
            }else {
                kProportion = 0.77
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //设置侧边栏滑动样式
        sideSlipStyle = SideSlipStyle.None
        //给主视图设置背景图
        let imageView = UIImageView(image: UIImage(named: "back"))
        imageView.frame = UIScreen.main.bounds
        view.addSubview(imageView)
        
        //homeVc的view放在背景视图上
        view.addSubview(homeViewController.view)
        
        //绑定
        homeViewController.panGesture.addTarget(self, action: #selector(ViewController.pan(recongnizer:)))
        
    }
    
    //响应手势触发
    func pan(recongnizer: UIPanGestureRecognizer) {
        let x = recongnizer.translation(in: self.view).x
        let trueDistance = distance + x // 实时距离
        
        // 如果 UIPanGestureRecognizer 结束，则激活自动停靠
        if recongnizer.state == UIGestureRecognizerState.ended {
            
            if trueDistance > Common.screenWidth * (kProportion / 3) {
                showLeft()
            } else if trueDistance < Common.screenWidth * -(kProportion / 3) {
                showRight()
            } else {
                showHome()
            }
            
            return
        }
        
        // 计算缩放比例
        var proportion: CGFloat = recongnizer.view!.frame.origin.x >= 0 ? -1 : 1
        proportion *= trueDistance / Common.screenWidth
        proportion *= 1 - kProportion
        proportion /= 0.6
        proportion += 1
        if proportion <= kProportion { // 若比例已经达到最小，则不再继续动画
            return
        }
        // 执行平移和缩放动画
        recongnizer.view!.center = CGPoint(x: self.view.center.x + trueDistance, y: self.view.center.y)
        recongnizer.view!.transform = CGAffineTransform(scaleX: proportion, y: proportion)
//            CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion)
    }
    //
    func showLeft() {
        distance = self.view.center.x * (kFullDistance + kProportion / 2)
        doTheAnimate(proportion: self.kProportion)
    }
    func showRight() {
        distance = self.view.center.x * -(kFullDistance + kProportion / 2)
        doTheAnimate(proportion: self.kProportion)
    }
    func showHome() {
        distance = 0
        doTheAnimate(proportion: 1)
    }
    
    func doTheAnimate(proportion: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: { 
            self.homeViewController.view.center = CGPoint(x: self.view.center.x + self.distance, y: self.view.center.y)
            self.homeViewController.view.transform = CGAffineTransform(scaleX: proportion, y: proportion)
            }, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

