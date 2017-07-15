//
//  TestViewController.swift
//  ZSTestSwift
//
//  Created by zhoushuai on 2017/7/14.
//  Copyright © 2017年 Zhoushuai. All rights reserved.
//

import UIKit

class TestViewController: BaseViewController {

    //MARK: - Own Properties
    //懒加载创建弹窗视图
    lazy var alertView:MyAlertView = {
        let alerView = MyAlertView()
        return alerView
    }()

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "测试界面"

     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - Event Response



    //测试单按钮弹窗
    @IBAction func testBtnClick_normal(_ sender: Any) {
        //因为这次的style类型为Normal，需要提前设置好UI参数
        self.alertView.alertTitle = "测试Title"
        self.alertView.alertContent = "测试Content"
        self.alertView.firstBtnTitle = "按钮Title"
        self.alertView.alertStyle = .Alert_Normal_oneBtn
        self.alertView.firstBtnAction = {
            [weak self] in
            self?.alertView .hideAlerViewAndRemove(removeFromSuperView:true)
        }
        self.alertView .showMyAlertView()
    }
    
    
    //测试双按钮弹窗
    @IBAction func testBtnClick_twoBtn(_ sender: Any) {
        //因为这次的style类型为Normal，需要提前设置好UI参数
        self.alertView.alertTitle = "测试Title"
        self.alertView.alertContent = "测试Content"
        self.alertView.firstBtnTitle = "按钮Title1"
        self.alertView.secondBtnTitle = "按钮Title2"
        self.alertView.alertStyle = .Alert_Normal_TwoBtn
        self.alertView.firstBtnAction = {
            [weak self] in
            self?.alertView .hideAlerViewAndRemove(removeFromSuperView:true)
        }
        self.alertView.seconBtnAction = {
            [weak self] in
            self?.alertView .hideAlerViewAndRemove(removeFromSuperView:true)
        }
        self.alertView .showMyAlertView()
    }
    
    
    
}
