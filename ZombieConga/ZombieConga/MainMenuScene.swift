//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Amy Joscelyn on 11/7/16.
//  Copyright © 2016 Amy Joscelyn. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene
{
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        self.addChild(background)
    }
    
    func sceneTapped()
    {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: reveal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        sceneTapped()
    }
}
