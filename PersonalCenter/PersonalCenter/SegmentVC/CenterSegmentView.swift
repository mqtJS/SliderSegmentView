//
//  CenterSegmentView.swift
//  PersonalCenter
//
//  Created by mqt on 2018/5/12.
//  Copyright © 2018年 mqt. All rights reserved.
//

import UIKit

class CenterSegmentView: UIView {
    
    /// huidiao
    typealias PageBlock = (_ selectedIndex:Int)->Void
    var pageBlock:PageBlock?
    
    /// 分页标题数组
    var nameArray:[String] = []
    
    /// 标题按钮高度
    var segmentScrollVHeight:CGFloat = 41
    
    /// 标题正常颜色
    var titleNormalColor:UIColor = UIColor.gray
    
    /// 标题选中颜色
    var titleSelectColor:UIColor = UIColor.orange
    
    /// 选中字体大小
    var selectFont = UIFont.systemFont(ofSize: 19)
    
    /// 未选中字体大小
    var normalFont = UIFont.systemFont(ofSize: 17)
    
    /// 选中线背景颜色
    var lineSelectedColor = UIColor.orange
    
    /// 分割线颜色
    var downColor = UIColor.gray
    
    /// 选中的index
    var selectedIndex:Int = 0
    
    /// 底部滑块高度
    var lineHeight:CGFloat = 1
    
    /// 包含分页标题view
    lazy var segmentView:UIScrollView = {
       let view = UIScrollView(frame: CGRect.zero)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    ///
    lazy var segmentScrollV:UIScrollView = {
       let view = UIScrollView()
        return view
    }()
    
    /// 选中下划线
    lazy var line:UILabel = {
       let label = UILabel(frame: CGRect.zero)
       
        return label
    }()
    
    /// 选中的按钮
    lazy var seleBtn:UIButton = {
       let btn = UIButton(frame: CGRect.zero)
        return btn
    }()
    
    /// 分割线
    lazy var down:UILabel = {
       let label = UILabel(frame: CGRect.zero)
         label.backgroundColor = UIColor.gray
        return label
    }()
    
    /// 子控件数组
    var controllers:[UIViewController] = []
    
//    convenience init(frame: CGRect,controllers:[UIViewController],titleArray:[String],parentController:UIViewController,selectIndex:Int,lineHieht:CGFloat) {
//        self.init(frame: frame)
//        self.controllers = controllers
//        self.nameArray = titleArray
//    }
    
    convenience init(frame: CGRect,controllers:[UIViewController],titleArray:[String],selectIndex:Int,lineHeight:CGFloat) {
        self.init(frame: frame)
        self.controllers = controllers
        self.nameArray = titleArray
        self.lineHeight = lineHeight
        self.initData()
    }
    
    func initData(){
        if self.nameArray.count == 0 && self.controllers.count == 0{
            return
        }
        //宽度
        let avgWidth = frame.size.width / CGFloat(self.controllers.count)
        self.segmentView.frame = CGRect(x: 0, y: 0, width:frame.size.width, height: segmentScrollVHeight)
        self.segmentView.tag = 50
        self.addSubview(self.segmentView)
        
        self.segmentScrollV.frame = CGRect(x: 0, y: self.segmentScrollVHeight, width: frame.size.width, height: frame.size.height - self.segmentScrollVHeight)
        self.segmentScrollV.contentSize = CGSize(width: frame.size.width * CGFloat(controllers.count), height: 0)
        self.segmentScrollV.delegate = self
        self.segmentScrollV.showsHorizontalScrollIndicator = false
        //是否开启平移，每次平移就是scrollView的宽度
        self.segmentScrollV.isPagingEnabled = true
        self.segmentScrollV.bounces = false
        
        self.addSubview(self.segmentScrollV)
        
        for (index,controller) in controllers.enumerated(){
            self.segmentScrollV.addSubview(controller.view)
            controller.view.frame = CGRect(x: CGFloat(index) * frame.size.width, y: 0, width: frame.size.width, height: frame.size.height)
//            parentController.addChildViewController(controller)
//            controller.didMove(toParentViewController: parentController)
        }
        
        for (index,_)in controllers.enumerated(){
            let btn = UIButton(type: UIButtonType.custom)
            btn.frame = CGRect(x: CGFloat(index) * frame.size.width / CGFloat(controllers.count), y: 0, width: frame.size.width / CGFloat(controllers.count), height: self.segmentScrollVHeight)
            btn.backgroundColor = UIColor.white
            btn.tag = index
            btn.setTitle(self.nameArray[index], for: .normal)
            btn.setTitleColor(self.titleNormalColor, for: .normal)
            btn.setTitleColor(self.titleSelectColor, for: .selected)
            btn.addTarget(self, action: #selector(self.Click(sender:)), for: .touchUpInside)
            
            if self.selectedIndex == index{
                btn.isSelected = true
                self.seleBtn = btn
                btn.titleLabel?.font = self.selectFont
                //初始化选中的控制器CGPoint(,0)
                self.segmentScrollV.setContentOffset(CGPoint(x: CGFloat(btn.tag) * self.frame.size.width, y: 0), animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectVC"), object: btn, userInfo: nil)
            }else{
                btn.isSelected = false
                btn.titleLabel?.font = self.normalFont
            }
            self.segmentView.addSubview(btn)
        }
        
        //分割线
        let downFrame = CGRect(x: 0, y: 40, width: frame.size.width, height: 0.5)
        self.down = UILabel(frame: downFrame)
        self.down.backgroundColor = self.downColor
        self.segmentView.addSubview(self.down)
        
        let lineFrame = CGRect(x: avgWidth + avgWidth * CGFloat(selectedIndex), y: self.segmentScrollVHeight - self.lineHeight, width: avgWidth, height: self.lineHeight)
        self.line = UILabel(frame: lineFrame)
        self.line.backgroundColor = self.lineSelectedColor
        self.line.tag = 100
        //初始化位置
        var lineCeter = self.line.center
        lineCeter.x = frame.size.width / CGFloat(controllers.count * 2) + frame.size.width / CGFloat(controllers.count) * CGFloat(self.seleBtn.tag)
        self.line.center = lineCeter
        self.segmentView.addSubview(self.line)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func Click(sender:UIButton){
        self.seleBtn.titleLabel?.font = self.normalFont
        self.seleBtn.isSelected = false
        self.seleBtn = sender
        self.pageBlock?(sender.tag)
        
        self.seleBtn.titleLabel?.font = self.selectFont
        self.seleBtn.isSelected = true
        
        self.segmentScrollV.setContentOffset(CGPoint(x: CGFloat(sender.tag) * self.frame.size.width, y: 0), animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectVC"), object: sender, userInfo: nil)
    }
}

extension CenterSegmentView:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let btn = self.segmentView.viewWithTag(Int(self.segmentScrollV.contentOffset.x / self.frame.size.width))
        self.seleBtn.isSelected = false
        self.seleBtn.titleLabel?.font = self.normalFont
        if let button = btn {
            self.seleBtn = button as! UIButton
            self.seleBtn.isSelected = true
            self.seleBtn.titleLabel?.font = self.selectFont
            self.pageBlock?(button.tag)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemWidth = scrollView.bounds.width / CGFloat(controllers.count)
        let offsetX = (itemWidth / scrollView.bounds.width) * scrollView.contentOffset.x
        let xoffset = offsetX - (CGFloat(self.selectedIndex) * itemWidth)
        self.line.transform = CGAffineTransform(translationX: xoffset, y: 0)
    }
}
