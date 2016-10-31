//
//  GameScene.swift
//  ZombieConga
//
//  Created by Amy Joscelyn on 10/31/16.
//  Copyright © 2016 Amy Joscelyn. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    let zombie1 = SKSpriteNode(imageNamed: "zombie1")
    
    //SpriteKit calls this method before it presents this scene in a view, so it's a good place to do some initial setup of the scene's contents
    override func didMove(to view: SKView)
    {
        backgroundColor = SKColor.black
        
        let background = SKSpriteNode(imageNamed: "background1")
        /* This does the same as pinning the center to the center of the scene, because this is pinning the bottom left of the background to the bottom left of the scene!
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
         */
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        
//        background.zRotation = CGFloat(M_PI) / 8
        
        addChild(background)
        
        zombie1.position = CGPoint(x: 400, y: 400)
        
        addChild(zombie1)
        
        let mySize = background.size
        print("Size: \(mySize)")
    }
}
