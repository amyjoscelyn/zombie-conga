//
//  GameViewController.swift
//  ZombieConga
//
//  Created by Amy Joscelyn on 10/31/16.
//  Copyright © 2016 Amy Joscelyn. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        let scene = GameScene(size: CGSize(width: 2048, height: 1536))
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        let skview = self.view as! SKView
        skview.showsFPS = true
        skview.showsNodeCount = true
        skview.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skview.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
