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
    let zombieAnimation: SKAction
    
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
        
        var textures: [SKTexture] = []
        for i in 1...4
        {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
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
        
//        zombie.run(SKAction.repeatForever(zombieAnimation))
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },
                SKAction.wait(forDuration: 2.0)])))
        // using a weak reference to `self` here, otherwise the closure passed to run(_ block:) will create a strong reference cycle and result in a memory leak
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run { [weak self] in
                self?.spawnCat()
                },
                SKAction.wait(forDuration: 1.0)])))
        
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
                stopZombieAnimation()
            } else
            {
                move(sprite: zombie, velocity: velocity)
                rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSecond)
            }
//        }
        
        boundsCheckZombie()
//        checkCollisions()
    }
    
    override func didEvaluateActions()
    {
        checkCollisions()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint)
    {
        let amountToMove = velocity * CGFloat(dt)
//        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint)
    {
        startZombieAnimation()
        
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
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: size.width + enemy.size.width / 2,
            y: CGFloat.random(
                min: playableRect.minY + enemy.size.height / 2,
                max: playableRect.maxY - enemy.size.height / 2))
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(x: -enemy.size.width / 2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func startZombieAnimation()
    {
        if zombie.action(forKey: "animation") == nil
        {
            zombie.run(
                SKAction.repeatForever(zombieAnimation),
                withKey: "animation")
        }
    }
    
    func stopZombieAnimation()
    {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnCat()
    {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX,
                              max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY,
                              max: playableRect.maxY))
        
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1, duration: 0.5)
        
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π / 8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func zombieHit(cat: SKSpriteNode)
    {
        cat.removeFromParent()
    }
    
    func zombieHit(enemy: SKSpriteNode)
    {
        enemy.removeFromParent()
    }
    
    func checkCollisions()
    {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame)
            {
                hitCats.append(cat)
            }
        }
        for cat in hitCats
        {
            zombieHit(cat: cat)
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame)
            {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies
        {
            zombieHit(enemy: enemy)
        }
    }
}
