//
//  GameScene.swift
//  Pongicky
//
//  Created by Alexandru Rosianu on 03/09/2018.
//  Copyright © 2018 AR. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let paddle: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let wall: UInt32 = 0x1 << 2
    static let enemy: UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let jumpSound = SKAction.playSoundFileNamed("Sounds/8bitVol1/Kick 001.wav", waitForCompletion: true)
    let kickSound = SKAction.playSoundFileNamed("Sounds/8bitVol1/Kick 001.wav", waitForCompletion: true)
    let deathSound = SKAction.playSoundFileNamed("Sounds/8bitVol1/Stutter Blip 001.wav", waitForCompletion: true)
    let painSoundList = [
        SKAction.playSoundFileNamed("Sounds/ouch/man-getting-hit.wav", waitForCompletion: true),
        SKAction.playSoundFileNamed("Sounds/ouch/ouch-1.wav", waitForCompletion: true)
    ]
    let screamSound = SKAction.playSoundFileNamed("Sounds/ouch/ouch-screem.wav", waitForCompletion: true)
    let evilHahaSound = SKAction.playSoundFileNamed("Sounds/haha/Evil_Laugh_Male_6.wav", waitForCompletion: true)
    let levelUpSound = SKAction.playSoundFileNamed("Sounds/level-up/level-up-3note2.wav", waitForCompletion: true)
    
    let playerPaddle = makePlayerPaddle()
    let ball = makeBall()
    let scoreLabel = makeScoreLabel()
    let levelLabel = makeLevelLabel()
    
    let ballTouchParticle = SKEmitterNode(fileNamed: "BallTouchParticle.sks")!
    let enemyExplosionParticle = SKEmitterNode(fileNamed: "EnemyExplosionParticle.sks")!
    
    var enemyList = [SKSpriteNode]()
    
    var score: Int = 0
    var level: Int = 1
    
    class func makePlayerPaddle() -> SKShapeNode {
        let playerPaddle = SKShapeNode(rectOf: CGSize(width: 150, height: 30), cornerRadius: 15)
        
        playerPaddle.fillColor = .blue
        playerPaddle.lineWidth = 0
        
        playerPaddle.physicsBody = SKPhysicsBody(polygonFrom: playerPaddle.path!)
        playerPaddle.physicsBody!.usesPreciseCollisionDetection = true
        playerPaddle.physicsBody!.allowsRotation = false
        playerPaddle.physicsBody!.affectedByGravity = false
        
        playerPaddle.physicsBody!.linearDamping = 2.3
        playerPaddle.physicsBody!.restitution = 0.5
        playerPaddle.physicsBody!.friction = 0.9
        
        playerPaddle.physicsBody!.categoryBitMask = PhysicsCategory.paddle
        playerPaddle.physicsBody!.contactTestBitMask = PhysicsCategory.all
        playerPaddle.physicsBody!.collisionBitMask = PhysicsCategory.all
        
        return playerPaddle
    }
    
    class func makeBall() -> SKShapeNode {
        let ball = SKShapeNode(rectOf: CGSize(width: 30, height: 30), cornerRadius: 15)
        
        ball.fillColor = .blue
        ball.lineWidth = 0
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.width / 2)
        ball.physicsBody!.usesPreciseCollisionDetection = true
        
        ball.physicsBody!.linearDamping = 0.1
        ball.physicsBody!.restitution = 0.5
        ball.physicsBody!.friction = 0.2
        
        ball.physicsBody!.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody!.contactTestBitMask = PhysicsCategory.all
        ball.physicsBody!.collisionBitMask = PhysicsCategory.all
        
        return ball
    }
    
    class func makeScoreLabel() -> SKLabelNode {
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        scoreLabel.zPosition = 100
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.fontSize = 20
        
        return scoreLabel
    }
    
    class func makeLevelLabel() -> SKLabelNode {
        let levelLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        levelLabel.zPosition = 100
        levelLabel.verticalAlignmentMode = .top
        levelLabel.fontSize = 20
        
        return levelLabel
    }
    
    class func makeEnemy() -> SKSpriteNode {
        let enemy = SKSpriteNode(imageNamed: "alex.png")
        
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, alphaThreshold: 0.5, size: enemy.size)
        enemy.physicsBody!.mass = 5
        enemy.physicsBody!.usesPreciseCollisionDetection = true
        enemy.physicsBody!.allowsRotation = true
        enemy.physicsBody!.affectedByGravity = false
        
        enemy.physicsBody!.linearDamping = 0.1
        enemy.physicsBody!.restitution = 0.5
        enemy.physicsBody!.friction = 0.2
        
        enemy.physicsBody!.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody!.contactTestBitMask = PhysicsCategory.all
        enemy.physicsBody!.collisionBitMask = PhysicsCategory.all
        
        return enemy
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // set up world
        
        physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody!.friction = 0
        physicsBody!.categoryBitMask = PhysicsCategory.wall
        physicsBody!.contactTestBitMask = PhysicsCategory.all
        physicsBody!.collisionBitMask = PhysicsCategory.all
        
        // set up nodes
        
        playerPaddle.position = CGPoint(x: size.width / 2, y: 50)
        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        
        scoreLabel.position = CGPoint(x: 10, y: size.height - 40)
        scoreLabel.horizontalAlignmentMode = .left
        
        levelLabel.position = CGPoint(x: size.width - 10, y: size.height - 40)
        levelLabel.horizontalAlignmentMode = .right
        
        ballTouchParticle.particleBirthRate = 0
        enemyExplosionParticle.particleBirthRate = 0
        
        // add nodes
        
        addChild(playerPaddle)
        addChild(ball)
        
        addChild(scoreLabel)
        addChild(levelLabel)
        
        addChild(ballTouchParticle)
        addChild(enemyExplosionParticle)
        
        // initial label display
        
        setScore(score: score, fade: true)
        setLevel(level: 1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            // adjust player paddle position
            
            let multiplier = CGFloat(100)
            let dx = (location.x - previousLocation.x) * multiplier
            let dy = (location.y - previousLocation.y) * multiplier
            
            playerPaddle.physicsBody!.applyForce(CGVector(dx: dx, dy: dy))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1: SKPhysicsBody
        var body2: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body2 = contact.bodyA
            body1 = contact.bodyB
        }
        
        // show particles on contact
        
        if body1.categoryBitMask & PhysicsCategory.ball != 0 || body2.categoryBitMask & PhysicsCategory.ball != 0 {
            let ox = contact.contactPoint.x - ball.position.x
            let oy = contact.contactPoint.y - ball.position.y
            
            run(SKAction.sequence([
                SKAction.customAction(withDuration: 0.1) { (node, f) in
                    self.ballTouchParticle.particleBirthRate = (f / 0.1) * 300
                    self.ballTouchParticle.position.x = self.ball.position.x + ox
                    self.ballTouchParticle.position.y = self.ball.position.y + oy
                },
                SKAction.customAction(withDuration: 0.1) { (node, f) in
                    self.ballTouchParticle.particleBirthRate = (1 - (f / 0.1)) * 300
                    self.ballTouchParticle.position.x = self.ball.position.x + ox
                    self.ballTouchParticle.position.y = self.ball.position.y + oy
                }
            ]))
        }
        
        // respawn ball (and enemy) on death
        
        if body1.categoryBitMask & PhysicsCategory.ball != 0
            && body2.categoryBitMask & PhysicsCategory.wall != 0 {
            let ball = body1.node as! SKShapeNode
            
            if contact.contactPoint.y < 5 {
                if level == 1 {
                    setScore(score: 0, fade: true)
                } else {
                    setScore(score: score - 1, fade: true)
                }
                ball.removeFromParent()
                ball.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
                addChild(ball)
            }
            
            if contact.contactPoint.y < 5 && level == 2 {
                let enemy = enemyList.first!
                enemy.xScale = 0.5
                enemy.yScale = 0.5
                run(evilHahaSound)
            }
        }
        
        // accumulate points
        
        if body1.categoryBitMask & PhysicsCategory.paddle != 0
            && body2.categoryBitMask & PhysicsCategory.ball != 0 {
            if contact.collisionImpulse > 30 {
                setScore(score: score + 1, fade: false)
                
                if level == 1 && score >= 10 {
                    setLevel(level: 2)
                    spawnLevel2()
                    run(levelUpSound)
                }
            }
        }
        
        if level == 2
            && body1.categoryBitMask & PhysicsCategory.ball != 0
            && body2.categoryBitMask & PhysicsCategory.enemy != 0 {
            if contact.collisionImpulse > 10 {
                setScore(score: score + 3, fade: false)
            }
        }
        
        // play collision sounds
        
        if contact.collisionImpulse > 5
            && body1.categoryBitMask & PhysicsCategory.paddle != 0
            && body2.categoryBitMask & PhysicsCategory.ball != 0 {
            run(jumpSound)
        }
        
        if contact.collisionImpulse > 5
            && body1.categoryBitMask & PhysicsCategory.ball != 0
            && body2.categoryBitMask & PhysicsCategory.wall != 0 {
            run(kickSound)
        }
        
        if level == 2
            && contact.collisionImpulse > 10
            && body1.categoryBitMask & PhysicsCategory.ball != 0
            && body2.categoryBitMask & PhysicsCategory.enemy != 0 {
            let enemy = body2.node as! SKSpriteNode
            if enemy.xScale < 0.35 {
                run(screamSound)
            } else {
                run(painSoundList[Int(arc4random_uniform(UInt32(painSoundList.count)))])
            }
        }
        
        if contact.contactPoint.y < 5
            && body1.categoryBitMask & PhysicsCategory.ball != 0
            && body2.categoryBitMask & PhysicsCategory.wall != 0 {
            run(deathSound)
        }
        
        // damage enemy
        
        if level == 2
            && body1.categoryBitMask & PhysicsCategory.ball != 0
            && body2.categoryBitMask & PhysicsCategory.enemy != 0 {
            if contact.collisionImpulse > 10 {
                for enemy in enemyList {
                    if enemy.xScale < 0.35 {
                        enemy.run(SKAction.sequence([
                            SKAction.wait(forDuration: 0.5),
                            SKAction.customAction(withDuration: 0, actionBlock: { (_, _) in
                                self.enemyExplosionParticle.position = enemy.position
                                self.enemyExplosionParticle.particleBirthRate = 2000
                                
                                enemy.removeFromParent()
                                
                                self.enemyList.removeAll()
                                self.setLevel(level: 3)
                                self.spawnLevel3()
                                self.run(self.levelUpSound)
                            }),
                            SKAction.wait(forDuration: 0.5),
                            SKAction.customAction(withDuration: 0, actionBlock: { (_, _) in
                                self.enemyExplosionParticle.particleBirthRate = 0
                            })
                        ]))
                    }
                    
                    enemy.xScale -= 0.1
                    enemy.yScale -= 0.1
                }
            }
        }
    }
    
    func setScore(score: Int, fade: Bool) {
        self.score = score
        if fade {
            scoreLabel.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.customAction(withDuration: 0, actionBlock: { (_, _) in self.scoreLabel.text = "Score: \(score)" }),
                SKAction.fadeIn(withDuration: 0.2)
            ]))
        } else {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    func setLevel(level: Int) {
        self.level = level
        levelLabel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.customAction(withDuration: 0, actionBlock: { (_, _) in self.levelLabel.text = "Level: \(level)" }),
            SKAction.fadeIn(withDuration: 0.2)
        ]))
    }
    
    func spawnLevel2() {
        let enemy = GameScene.makeEnemy()
        
        enemy.position = CGPoint(x: size.width * 0.5, y: size.height * 0.8)
        enemy.xScale = 0.5
        enemy.yScale = 0.5
        
        enemyList.append(enemy)
        addChild(enemy)
    }
    
    func spawnLevel3() {
//        for i in 0..<2 {
//            for j in 0..<5 {
//                let enemy = GameScene.makeEnemy()
//                
//                enemy.position = CGPoint(x: 10 + j * 50, y: Int(size.height) - 70 - i * 50)
//                enemy.xScale = 0.1
//                enemy.yScale = 0.1
//                
//                enemyList.append(enemy)
//                addChild(enemy)
//            }
//        }
    }

}
