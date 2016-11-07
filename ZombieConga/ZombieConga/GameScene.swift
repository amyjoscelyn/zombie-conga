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
    let catMovePointsPerSecond: CGFloat = 480.0
    let zombieRotateRadiansPerSecond: CGFloat = 4.0 * π
    var velocity = CGPoint.zero //CGPoints can also represent 2D vectors
    // 2D Vectors represent a direction and a length (such as points per second)
    let playableRect: CGRect
    var lastTouchLocation = CGPoint.zero
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var invincible = false
    var lives = 5
    var gameOver = false
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSecond: CGFloat = 200.0
    var cameraRect: CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width) / 2
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height) / 2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
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
        zombie.zPosition = 100
        
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
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        backgroundColor = SKColor.black
        
        /* BEFORE CAMERANODE
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
 */
        /* AFTER CAMERANODE
        let background = backgroundNode()
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
        background.name = "background"
        addChild(background)
 */
        
        // LOOPING BACKGROUND CONTINUOUSLY
        for i in 0...1
        {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            addChild(background)
        }
        
//        let mySize = background.size
//        print("Size: \(mySize)")
        
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
        
//        debugDrawPlayableArea()
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
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
        
        /*
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
 */
        
        // To keep zombie going in direction of tap
        move(sprite: zombie, velocity: velocity)
        rotate(
            sprite: zombie,
            direction: velocity,
            rotateRadiansPerSec: zombieRotateRadiansPerSecond)
        
        boundsCheckZombie()
        moveTrain()
        moveCamera()
        
        if lives <= 0 && !gameOver
        {
            gameOver = true
            print("You lose!")
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
//        cameraNode.position = zombie.position
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
        /* BEFORE CAMERANODE
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
 */
        //AFTER CAMERANODE
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        if zombie.position.x <= bottomLeft.x
        {
            zombie.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
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
            x: cameraRect.maxX + enemy.size.width / 2,
            y: CGFloat.random(
                min: cameraRect.minY + enemy.size.height / 2,
                max: cameraRect.maxY - enemy.size.height / 2))
        enemy.zPosition = 50
        addChild(enemy)
        
        let actionMove = SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 2.0)
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
            x: CGFloat.random(min: cameraRect.minX,
                              max: cameraRect.maxX),
            y: CGFloat.random(min: cameraRect.minY,
                              max: cameraRect.maxY))
        cat.zPosition = 50
        
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
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        
        let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        
        cat.run(turnGreen)
        
        run(catCollisionSound)
    }
    
    func zombieHit(enemy: SKSpriteNode)
    {
        invincible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.zombie.isHidden = false
            self?.invincible = false
        }
        zombie.run(SKAction.sequence([blinkAction, setHidden]))
        
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
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
        
        if invincible
        {
            return
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
    
    override func didEvaluateActions()
    {
        checkCollisions()
    }
    
    func moveTrain()
    {
        var trainCount = 0
        var targetPosition = zombie.position
        
        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1
            if !node.hasActions()
            {
                let actionDuration = 0.3
                let offset = targetPosition - node.position //it's important here that targetPosition comes first, otherwise the cats will split away from the zombie
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSecond
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 15 && !gameOver
        {
            gameOver = true
            print("You win!")
            
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func loseCats()
    {
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: π * 4, duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            loseCount += 1
            
            if loseCount >= 2
            {
                stop[0] = true
            }
        }
    }
    
    func backgroundNode() -> SKSpriteNode
    {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera()
    {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSecond, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x
            {
                background.position = CGPoint(
                    x: background.position.x + background.size.width * 2,
                    y: background.position.y)
            }
        }
    }
}
