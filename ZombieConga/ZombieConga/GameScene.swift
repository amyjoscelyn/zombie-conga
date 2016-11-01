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
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSecond: CGFloat = 480.0
    let zombieRotateRadiansPerSecond: CGFloat = 4.0 * π
    var velocity = CGPoint.zero //CGPoints can also represent 2D vectors
    // 2D Vectors represent a direction and a length (such as points per second)
    let playableRect: CGRect
    var lastTouchLocation = CGPoint.zero
    
    //SpriteKit calls this method before it presents this scene in a view, so it's a good place to do some initial setup of the scene's contents
    
    override init(size: CGSize)
    {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0,
                              y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder) has not been implemented")
    }
    
    func debugDrawPlayableArea()
    {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
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
        
//        background.zRotation = CGFloat(M_PI) / 8 //to rotate the background, or anything else, by radians
        
        addChild(background)
        
        let mySize = background.size
        print("Size: \(mySize)")
        
        zombie.position = CGPoint(x: 400, y: 400)
//        zombie1.setScale(2) //to double the size of the zombie asset
        
        addChild(zombie)
        
        spawnEnemy()
        
        debugDrawPlayableArea()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if lastUpdateTime > 0
        {
            dt = currentTime - lastUpdateTime
        } else
        {
            dt = 0
        }
        lastUpdateTime = currentTime
//        print("\(dt*1000) milliseconds since last update")
        
        /*
         check distance between last touch location and zombie's position
         if the remaining distance is <= to the amount the zombie will move this frame, set the zombie's position to last touch location, and velocity to 0
         else move and rotate like normal
         boundscheckzombie should always occur
         */
        
//        if let lastTouchLocation = lastTouchLocation
//        {
            let diff = lastTouchLocation - zombie.position
            if diff.length() <= zombieMovePointsPerSecond * CGFloat(dt)
            {
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
            } else
            {
                move(sprite: zombie, velocity: velocity)
                rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSecond)
            }
//        }
        
        boundsCheckZombie()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint)
    {
        let amountToMove = velocity * CGFloat(dt)
//        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint)
    {
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSecond
    }
    
    func sceneTouched(touchLocation: CGPoint)
    {
        moveZombieToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first
            else
        {
            return
        }
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation: touchLocation)
    }
    
    func boundsCheckZombie()
    {
//        let bottomLeft = CGPoint.zero
//        let topRight = CGPoint(x: size.width, y: size.height)
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x
        {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x
        {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y
        {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y
        {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat)
    {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy()
    {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width / 2,
                                 y: size.height / 2)
        addChild(enemy)
        
        /* Initial move action
        let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width / 2,
                                                   y: enemy.position.y),
                                       duration: 2.0)
         */
        
        /* More complex move sequence
        let actionMidMove = SKAction.move(
            to: CGPoint(x: size.width / 2,
                        y: playableRect.minY + enemy.size.height / 2),
            duration: 1.0)
        let actionMove = SKAction.move(
            to: CGPoint(x: -enemy.size.width / 2,
                        y: enemy.position.y),
            duration: 1.0)
        let wait = SKAction.wait(forDuration: 0.25)
        let logMessage = SKAction.run {
            print("Reached bottom!")
        }
        
        let sequence = SKAction.sequence(
         [actionMidMove, logMessage, wait, actionMove])
         */
        
        /* new sequence, because moveBy(x:y:duration) is reversible!
        let actionMidMove = SKAction.moveBy(
            x: -size.width / 2 - enemy.size.width / 2,
            y: -playableRect.height / 2 + enemy.size.height / 2,
            duration: 1.0)
        let actionMove = SKAction.moveBy(
            x: -size.width / 2 - enemy.size.width / 2,
            y: playableRect.height / 2 - enemy.size.height / 2,
            duration: 1.0)
        let reverseMid = actionMidMove.reversed()
        let reverseMove = actionMove.reversed()
        
        let wait = SKAction.wait(forDuration: 0.25)
        let logMessage = SKAction.run {
            print("Reached bottom!")
        }
        
        let sequence = SKAction.sequence(
         [actionMidMove, logMessage, wait, actionMove, reverseMove, logMessage, wait, reverseMid]) */
        
        // sequences are also reversible!
        let actionMidMove = SKAction.moveBy(
            x: -size.width / 2 - enemy.size.width / 2,
            y: -playableRect.height / 2 + enemy.size.height / 2,
            duration: 1.0)
        let actionMove = SKAction.moveBy(
            x: -size.width / 2 - enemy.size.width / 2,
            y: playableRect.height / 2 - enemy.size.height / 2,
            duration: 1.0)
        let wait = SKAction.wait(forDuration: 0.25)
        let logMessage = SKAction.run {
            print("Reached bottom!")
        }
        
        let halfSequence = SKAction.sequence(
            [actionMidMove, logMessage, wait, actionMove])
        let sequence = SKAction.sequence([
            halfSequence, halfSequence.reversed()])
        
        let repeatAction = SKAction.repeatForever(sequence)
        enemy.run(repeatAction)
    }
}
