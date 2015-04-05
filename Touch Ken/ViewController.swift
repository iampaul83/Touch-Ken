//
//  ViewController.swift
//  Touch Ken
//
//  Created by Paul on 3/30/15.
//  Copyright (c) 2015 Paul. All rights reserved.
//

import UIKit
/// 測試KenImageView的使用
class ViewController: UIViewController, UIGestureRecognizerDelegate
{
    @IBOutlet weak var instructionKen: KenImageView!
    @IBOutlet weak var instructionLabelHead: UILabel!
    @IBOutlet weak var instructionLabelBody: UILabel! {
        didSet {
            instructionLabelBody.text =
                "點擊畫面以召喚Ken\n" + 
                "用手指移動Ken\n" +
                "用雙指改變Ken的大小\n" +
                "雙指可邊改變大小邊移動Ken\n" +
                "雙指向內擠壓可殺掉Ken\n" +
                "連點兩下以關閉說明"
        }
    }
    private func removeInstructions() {
        if instructionLabelHead == nil { return
            println("What're you doing, instructionLabels's already removed!!!!!")
        }
        instructionLabelHead.removeFromSuperview()
        instructionLabelBody.removeFromSuperview()
        instructionKen.removeFromSuperview()
    }
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    // UIResponder way
    // 連點兩下關閉說明文字
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let touch = touches.anyObject() as? UITouch {
            if instructionLabelHead != nil {
                if touch.tapCount == 2 {
                    removeInstructions()
                }
            }
        }
    }
    
    /// 點擊畫面以生出一隻Ken
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(view)
        addKen(at: location)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // 不在Ken身上重複生出Ken
        if gestureRecognizer == tapGestureRecognizer {
            return touch.view == view
        }
        return true
    }
    
    private func addKen(at location: CGPoint) {
        let ken = KenImageView(center: location)
        ken.delegate = self
        view.addSubview(ken)
    }
    
    @IBAction func goRight(sender: UIButton) {
        makeKens {$0.goRight()}
    }
    @IBAction func goLeft(sender: UIButton) {
        makeKens {$0.goLeft()}
    }
    private func makeKens(move: KenImageView -> Void ) {
        // all kens is your's
        for subview in view.subviews {
            if let ken = subview as? KenImageView {
                move(ken)
            }
        }
    }
}

extension ViewController: KenImageViewDelegate
{
    func kenDidFinishedMoving(ken: KenImageView) {
        // println("kenDidFinishedMoving")
        // ken 有 1/5 的機率移動後暴斃...
        if arc4random() % 5 == 0 { ken.removeFromSuperview() }
    }
}
