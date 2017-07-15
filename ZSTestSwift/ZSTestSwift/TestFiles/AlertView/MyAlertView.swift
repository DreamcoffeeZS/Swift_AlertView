//
//  MyAlertView.swift
//  SwiftConsultant
//
//  Created by zhoushuai on 2017/7/12.
//  Copyright © 2017年 Zhoushuai. All rights reserved.
//

import UIKit
import SnapKit
/*
 使用说明：自定义的弹窗视图，具有很好的扩展性，只要增加新的枚举类型就可以适用新的弹窗UI需求具体。
 使用要求：导入SnapKit自动布局库
*/

//定义一个点击闭包，在外界点击按钮时，执行闭包
typealias MyAlertViewBtnAction = () -> ()

//自定义弹窗
class MyAlertView: UIView {
    //嵌套枚举：根据不同的类型，布局弹窗
    enum MyAlertViewStyle {
        case Alert_Normal_oneBtn   //普通(单一按钮)：需要传入外界参数，包括标题、内容和按钮标题等
        case Alert_Normal_TwoBtn   //普通(双按钮）:需要外界布局参数
        case Alert_LogInFailed     //指定类型(单一按钮)：在alertStyle属性监听器中设置属性
        case Alert_ChoosePicture   //样式差别比较大的弹窗需要特殊处理，包括动画和其他布局
    }

    //MARK: - Own Properties
    //MARK:弹窗之前可以外部设置的参数
    var alertTitle        = "" //弹窗标题
    var alertContent      = "" //内容信息
    var firstBtnTitle     = "" //按钮1-3的文字
    var secondBtnTitle    = ""
    var thirdBtnTitle     = ""
    var firstBtnAction:MyAlertViewBtnAction? //按钮1-3的闭包回调
    var seconBtnAction:MyAlertViewBtnAction?
    var thirdBtnAction:MyAlertViewBtnAction?

    //MARK:布局弹窗使用的默认参数
    let mainViewLeftPadding = 50.0  //主视图距离屏幕两端的距离
    let subViewLeftPadding  = 15.0  //主视图上子控件距离左边缘的距离
    let subviewTopPadding = 15.0    //主视图上子控件距离上边缘的距离
    let lineViewHeight = 0.5        //主视图分割线高度
    let btnHeight = 45.0            //主视图上按钮的高度
    let backgroundViewAlpha:CGFloat = 0.5
    let titleLabelFont = UIFont.systemFont(ofSize: 17) //标题文字、内容文字、按钮文字大小
    let contentLabelFont = UIFont.systemFont(ofSize: 13)
    let buttonTitleFont = UIFont.systemFont(ofSize: 15)
    let backgroundViewColor = UIColor.black //背景色、主视图、分割线等颜色
    let mainViewColor = UIColor.white
    let lineViewColor = UIColor.gray
    let buttonBackgroundColor = UIColor.white
    let buttonTitleNormalColor = UIColor.black
    let buttonTitleAnotherColor = UIColor.red
    let windowWidth = UIScreen.main.bounds.size.width
    let windowHeight = UIScreen.main.bounds.size.height

    var gestureEnable:Bool = false //点击手势是否可以使用

    //MARK:UI控件懒加载
    lazy var backgroundView:UIView = {
        let backgroundView = UIView.init()
        backgroundView.backgroundColor = self.backgroundViewColor
        backgroundView.alpha = self.backgroundViewAlpha
        return backgroundView
    }()
    
    lazy var mainView:UIView = {
       let mainView = UIView.init()
        mainView.backgroundColor = self.mainViewColor
        mainView.layer.cornerRadius = 8;
        mainView.layer.masksToBounds = true
        return mainView
    }()
    
    lazy var titleLabel:UILabel = {
        //标题Label
        let titleLabel = UILabel.init()
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = self.titleLabelFont
        return titleLabel
    }()
    
    lazy var contentLabel:UILabel = {
        //内容Label
        let contentLabel = UILabel.init()
        contentLabel.textAlignment = NSTextAlignment.center
        contentLabel.numberOfLines = 0
        contentLabel.font = self.contentLabelFont
        return contentLabel
    }()
    
    lazy var lineOneView:UIView = {
        //分割线1
        let lineOneView = UIView.init()
        lineOneView.backgroundColor = self.lineViewColor
        return lineOneView
    }()
    
    lazy var lineTwoView:UIView = {
        //分割线2
        let lineTwoView = UIView.init()
        lineTwoView.backgroundColor = self.lineViewColor
        return lineTwoView
    }()
    
    
    lazy var firstBtn:UIButton = {
        //按钮1
        let firstBtn:UIButton = self.createButton()
        firstBtn.addTarget(self, action: #selector(firstBtnClick), for: .touchUpInside)
        return firstBtn
    }()
    
    lazy var secondBtn:UIButton = {
        //按钮2
        let secondBtn:UIButton = self.createButton()
        secondBtn.addTarget(self, action: #selector(secondBtnClick), for: .touchUpInside)
        return secondBtn
    }()
    
    lazy var thirdBtn:UIButton = {
        //按钮3
        let thirdBtn:UIButton = self.createButton()
        thirdBtn.addTarget(self, action: #selector(thirdBtnClick), for: .touchUpInside)
        return thirdBtn
    }()


    //属性监听器，在修改了样式之后重新设置弹窗
    var alertStyle: MyAlertViewStyle = .Alert_Normal_oneBtn{
        didSet {
            self.resetUI()
            self.updateUI()
        }
    }
    
    
    
    
    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        //添加背景和MainView控件
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self)
        }
        self.addSubview(self.mainView)
        self.resetUI()
        //添加点击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        singleTap.delegate = self
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    
    
    //MARK: - Public Methods
    func showMyAlertView(){
        self.isHidden = false
        //设置弹窗视图的父视图为当前的主Window
        if(self.superview == nil){
            let window = UIApplication.shared.delegate?.window
            window??.addSubview(self)
            self.snp.remakeConstraints { (make) in
                make.top.equalTo((self.superview!.snp.top)).offset(0)
                make.left.right.equalTo(self.superview!)
                make.height.equalTo(windowHeight)
            }
        }
        self.superview!.bringSubview(toFront: self)
        //由于视图样式不一，可能弹出效果也不一样
        switch self.alertStyle {
        case .Alert_ChoosePicture:
            break;
        default:
            self.mainView .showAlertViewAnimation()
            self.snp.updateConstraints { (make) in
                make.top.equalTo(self.superview!.snp.top).offset(0)
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.alpha = 1
            }, completion: { (finished) in
                //
            })
            break;
        }
    }
    
    func delayMyAlertView(){
        self.perform(#selector(showMyAlertView), with: nil, afterDelay: 0.5)
    }
    
    func hideAlerViewAndRemove(removeFromSuperView:Bool){
        //由于视图样式不一，动画效果也不一样
        switch self.alertStyle {
        case .Alert_ChoosePicture:
            break;
        default:
            self.mainView.hideAlertDisappearAnimation()
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.alpha = 0
            }) { (finished) in
                //隐藏视图到底部
                self.isHidden = true
                self.snp.updateConstraints { (make) in
                    make.top.equalTo(self.superview!.snp.top).offset(self.windowHeight)
                }
                //从父视图中移除
                if removeFromSuperView{
                    self.removeFromSuperview()
                }
            }
            break;
        }
    }
    


    //MARK: - Private Methods
    private func resetUI(){
        //关闭单击手势
       // self.gestureEnable = false
        //移除mainView上的所有视图
        for view in self.mainView.subviews{
            view.removeFromSuperview()
        }
        
        self.mainView.snp.remakeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self).offset(mainViewLeftPadding)
            make.right.equalTo(self).offset(-mainViewLeftPadding)
        }
    }
    
    
    private func updateUI(){
        switch self.alertStyle {
        case .Alert_Normal_oneBtn:
            self.updateUIForNormal_oneBtn()
        case .Alert_Normal_TwoBtn:
            self.updateUIForNormal_twoBtn()
        default:
            break
        }
    }
    
    
    private func createButton()->(UIButton){
        let button = UIButton.init(type: .custom)
        button.backgroundColor = self.buttonBackgroundColor
        button.titleLabel?.font  = buttonTitleFont
        button.setTitleColor(buttonTitleNormalColor, for:.normal)
        return button
    }
    
    
    //更新UI
    //普通：一个按钮
    private func updateUIForNormal_oneBtn(){
        self.mainView.addSubview(self.titleLabel)
        self.titleLabel.text = self.alertTitle
        self.titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.mainView).offset(15)
            make.left.equalTo(self.mainView).offset(15)
            make.right.equalTo(self.mainView).offset(-15)
        }
        
        self.mainView.addSubview(self.contentLabel)
        self.contentLabel.text = self.alertContent
        self.contentLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalTo(self.mainView).offset(15)
            make.right.equalTo(self.mainView).offset(-15)
        }
        
        self.mainView.addSubview(self.lineOneView)
        self.lineOneView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(15)
            make.left.right.equalTo(self.mainView)
            make.height.equalTo(lineViewHeight)
        }
        
        self.mainView.addSubview(self.firstBtn)
        self.firstBtn.setTitle(self.firstBtnTitle, for:.normal)
        self.firstBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(self.lineOneView.snp.bottom)
            make.left.right.equalTo(self.mainView)
            make.height.equalTo(btnHeight)
            make.bottom.equalTo(self.mainView)
        }
    }
    
    //普通：两个按钮
    private func updateUIForNormal_twoBtn(){
        self.mainView.addSubview(self.titleLabel)
        self.titleLabel.text = self.alertTitle
        self.titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.mainView).offset(15)
            make.left.equalTo(self.mainView).offset(15)
            make.right.equalTo(self.mainView).offset(-15)
        }
        
        self.mainView.addSubview(self.contentLabel)
        self.contentLabel.text = self.alertContent
        self.contentLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalTo(self.mainView).offset(15)
            make.right.equalTo(self.mainView).offset(-15)
        }
        
        self.mainView.addSubview(self.lineOneView)
        self.lineOneView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(15)
            make.left.right.equalTo(self.mainView)
            make.height.equalTo(lineViewHeight)
        }
        
        self.mainView.addSubview(self.lineTwoView)
        self.lineTwoView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.lineOneView.snp.bottom).offset(0)
            make.width.equalTo(0.5)
            make.centerX.equalTo(self.lineOneView.snp.centerX)
            make.height.equalTo(btnHeight)
        }

        self.mainView.addSubview(self.firstBtn)
        self.firstBtn.setTitle(self.firstBtnTitle, for:.normal)
        self.firstBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(self.lineOneView.snp.bottom)
            make.left.equalTo(self.lineOneView.snp.left)
            make.right.equalTo(self.lineTwoView.snp.left)
            make.height.equalTo(btnHeight)
            make.bottom.equalTo(self.mainView)
        }
        
        self.mainView.addSubview(self.secondBtn)
        self.secondBtn.setTitle(self.secondBtnTitle, for:.normal)
        self.secondBtn.snp.remakeConstraints { (make) in
            make.top.equalTo(self.lineOneView.snp.bottom)
            make.left.equalTo(self.lineTwoView.snp.right)
            make.right.equalTo(self.mainView.snp.right)
            make.height.equalTo(btnHeight)
        }
    }
    
    
    //MARK: - Event Response
    func firstBtnClick(){
        if let firstBtnAction = self.firstBtnAction {
            firstBtnAction()
        }
    }
    
    func secondBtnClick(){
        if let secondBtnAction = self.seconBtnAction {
            secondBtnAction()
        }
    }
    
    func thirdBtnClick(){
        if let thirdBtnAction = self.seconBtnAction{
            thirdBtnAction()
        }
    }
    
    
    func singleTapAction(){
        if(gestureEnable){
            self.hideAlerViewAndRemove(removeFromSuperView: true)
        }
    }

}



//MARK: - Extension - 手势处理扩展
extension MyAlertView:UIGestureRecognizerDelegate {
    
}


//MARK: - Extension - 专门为Main增加的动画扩展
extension UIView{
    
    //弹窗效果：弹簧效果出现
    func showAlertViewAnimation(){
        let forwardAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        forwardAnimation.duration = 0.5
        forwardAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.7, 0.6, 0.85)
        forwardAnimation.fromValue = NSNumber(value: 0.0)
        forwardAnimation.toValue   = NSNumber(value: 1.0)
        self.layer.add(forwardAnimation, forKey:"showAlertViewAnimation")
    }
    
    //弹窗效果：弹簧效果消失
    func hideAlertDisappearAnimation(){
        let reverseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        reverseAnimation.duration = 0.5
        reverseAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.15, 0.5, -0.7)
        reverseAnimation.fromValue = NSNumber(value:1.0)
        reverseAnimation.toValue = NSNumber(value:0.0)
        reverseAnimation.fillMode = kCAFillModeForwards
        reverseAnimation.isRemovedOnCompletion = true
        self.layer.add(reverseAnimation, forKey:"hideAlertDisappearAnimation")
    }
}





