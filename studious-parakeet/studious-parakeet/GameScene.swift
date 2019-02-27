//
//  GameScene.swift
//  studious-parakeet
//
//  Created by Harry Woodworth on 2/18/19.
//  Copyright © 2019 Harry Woodworth. All rights reserved.
//
//  Finished 2/27/2019
//
//  References:
//      https://www.raywenderlich.com/71-spritekit-tutorial-for-beginners
//      http://mammothinteractive.com/touches-and-moving-sprites-in-xcode-spritekit-swift-crash-course-free-tutorial/
//      https://stackoverflow.com/questions/25277956/move-a-node-to-finger-using-swift-spritekit
//      https://www.hackingwithswift.com/read/14/4/whack-to-win-skaction-sequences
//      https://www.raywenderlich.com/144-spritekit-animations-and-texture-atlases-in-swift
//      https://www.appcoda.com/spritekit-introduction/
//      https://developer.apple.com/documentation/swift/string
//      https://stackoverflow.com/questions/34624292/change-time-interval-in-skaction-waitforduration-as-game-goes-on
//      https://developer.apple.com/documentation/spritekit/skphysicsbody/1519774-affectedbygravity
//      https://stackoverflow.com/questions/19206762/equivalent-to-shared-preferences-in-ios
//

import SpriteKit

// Constraints for physics categories
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let debris    : UInt32 = 0b1      // debris (1)
    static let player    : UInt32 = 0b10     // Player (2)
}

class GameScene: SKScene
{
    // Player sprite
    private var player = SKSpriteNode()
    // Texture array for player animation
    private var playerBoostFrames: [SKTexture] = []
    // Current move action used by the player
    private var currentAction: SKAction? = nil
    
    // Time between debris spawn
    private var debrisWaitDuration = 2.0
    
    // Current Score
    private var score = 0
    // High score
    private var highScore = 0
    // Label to display score
    private var scoreLabel = SKLabelNode()
    // Label to display high score
    private var highScoreLabel = SKLabelNode()
   
    // Preferences for storing/modifying high score
    private let preferences = UserDefaults.standard
    // Preferences Key for high score value
    private let highScoreKey = "HIGH_SCORE_KEY"
    
    
    // Runs after the scene is presented to the view
    override func didMove(to view: SKView)
    {
        // Set the background color
        backgroundColor = SKColor.black
        
        // Add player sprite
        buildPlayerSprite()
        
        // Ignore gravity, set contact delegate to self for collision (uses extention at bottom)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Animate player sprite
        animatePlayerBoost()
        
        // Get high score from preferences
        highScore = preferences.integer(forKey: highScoreKey)
        
        // Add score label
        buildScoreLabel()
        
        // Run update game in a loop
        run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(updateGame),
                    SKAction.wait(forDuration: 0.01)
                ])
            ))
        
        // Run addStar in a loop
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addStar),
                SKAction.wait(forDuration: 0.1)
                ])
        ))
        
        // Run addDebris in a recursive loop
        run(SKAction.run(debrisRecursiveLoop))
        
        // Run scoring/debris duration modifier in a loop
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(scoreDebrisMod),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
    }
    
    // Recursive loop that spawns debris using a changing debrisWaitDuration
    // Recursive because we need to change the SKAction.wait duration each loop
    func debrisRecursiveLoop()
    {
        let recursive = SKAction.sequence([
                            SKAction.wait(forDuration: debrisWaitDuration),
                            SKAction.run(addDebris),
                            SKAction.run({[unowned self] in NSLog("Block executed"); self.debrisRecursiveLoop()})
                        ])
        run(recursive, withKey: "RecursiveDebrisLoop")
    }
    
    // Create player sprite through texture atlas
    func buildPlayerSprite()
    {
        // Create the animation using the atlas
        let playerBoostAtlas = SKTextureAtlas(named: "PlayerBoost")
        var boostFrames: [SKTexture] = []
        let numImages = playerBoostAtlas.textureNames.count
        for i in 1...numImages {
            let textureName = "player-boost\(i)"
            boostFrames.append(playerBoostAtlas.textureNamed(textureName))
        }
        
        // Set the animation to the player
        playerBoostFrames = boostFrames
        
        // Create player sprite
        player = SKSpriteNode(texture: playerBoostFrames[0])
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.setScale(1.5)

        // Player phsyicsbody for collisions
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.debris
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        // Add to scene
        addChild(player)
    }
    
    // Create and position the score label / high score label
    func buildScoreLabel()
    {
        // Score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 10)
        addChild(scoreLabel)
        
        // High score label
        highScoreLabel = SKLabelNode(text: "HighScore: \(highScore)")
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 15)
        addChild(highScoreLabel)
    }
    
    // Animation loop for the player that runs forever
    func animatePlayerBoost()
    {
        player.run(
            SKAction.repeatForever(
                SKAction.animate(with: playerBoostFrames,
                                 timePerFrame: 0.1,
                                 resize: false,
                                 restore: true)),
            withKey:"PlayerBoosting")
    }
    
    // Run the curent action (prevents action stacking / teleporting)
    func updateGame()
    {
        if(currentAction != nil) {
            player.run(currentAction!)
        }
    }
    
    // Add touches to the action sequence
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // Get the first touch
        guard let touch = touches.first else { return }
        let touchLoc = touch.location(in: self)
        
        // Direction from player to touch
        let direction = player.position - touchLoc
        
        // Set the move action (modified to make short moves not super slow)
        currentAction = SKAction.move(to: touchLoc, duration: 0.5 * Double(direction.length()/100) )
    }
    
    // Create debris objects
    func addDebris()
    {
        let debris = SKSpriteNode(imageNamed: "Debris")
        
        // Make it a random size
        let sizeRandom = random(min: 1.0, max: 5.0 )
        
        // Set the scale
        debris.setScale(sizeRandom)
        
        // Set the physics body
        debris.physicsBody = SKPhysicsBody(circleOfRadius: debris.size.width / 2)
        debris.physicsBody?.isDynamic = true
        debris.physicsBody?.categoryBitMask = PhysicsCategory.debris
        debris.physicsBody?.contactTestBitMask = PhysicsCategory.player
        debris.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Random position on X axis
        let randomX = random(min: 0, max: size.width)
        debris.position = CGPoint(x: randomX, y: size.height + debris.size.height)
        
        // Add to scene
        addChild(debris)
        
        // Random speed move action down screen
        let randomDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        let moveAction = SKAction.move(to: CGPoint(x: randomX, y: -debris.size.height), duration: TimeInterval(randomDuration))
        
        // Delete action
        let deleteAction = SKAction.removeFromParent()
        
        // Run actions
        debris.run(SKAction.sequence([moveAction,deleteAction]))

    }
    
    // Create a star off screen at the top
    func addStar()
    {
        let star = SKSpriteNode(imageNamed: "Star")
        
        // Random size
        star.setScale(random(min: 0.5, max: 4.0 ))
        
        // Random position on x axis
        let randomX = random(min: 0, max: size.width)
        star.position = CGPoint(x: randomX, y: size.height + star.size.height)
        
        // Add to scene
        addChild(star)
        
        // Random speed move down screen
        let randomDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        let moveAction = SKAction.move(to: CGPoint(x: randomX, y: -star.size.height), duration: TimeInterval(randomDuration))
        
        // Delete action
        let deleteAction = SKAction.removeFromParent()
        
        // Run actions
        star.run(SKAction.sequence([moveAction,deleteAction]))
    }
    
    // Increase the score and decrease the debris wait duration
    func scoreDebrisMod()
    {
        // Increment score
        score += 1
        // Update score label text
        scoreLabel.text = "Score: \(score)"
        
        // Update high Score text
        if(score > highScore)
        {
            highScoreLabel.text = "High Score: \(score)"
        } else {
            highScoreLabel.text = "High Score: \(highScore)"
        }
        
        // Decrement debrisWaitDuration, min in 0.3
        if(debrisWaitDuration > 0.3) {
            debrisWaitDuration -= 0.02
        } else {
            // Fixes negative jump number glitch
            debrisWaitDuration = 0.3
        }
    }
    
    // Called by extention when a collision between player and debris happens
    func playerCollidedWithDebris(player: SKSpriteNode, debris: SKSpriteNode)
    {
        // Update high score
        if score > highScore
        {
            // Set high score
            highScore = score
            // Write to preferences
            preferences.set(highScore, forKey: highScoreKey)
            // Save preferences
            preferences.synchronize()
        }
        
        // Reset score and debris wait duration
        score = 0
        debrisWaitDuration = 2.0
    }
    
    // Random calculation helper functions
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
}

// Extension for collision detection
extension GameScene: SKPhysicsContactDelegate
{
    func didBegin(_ contact: SKPhysicsContact)
    {
        // Detect a collision
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Call playerCollidedWithDebris
        if ((firstBody.categoryBitMask & PhysicsCategory.debris != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.player != 0)) {
            if let debris = firstBody.node as? SKSpriteNode,
                let player = secondBody.node as? SKSpriteNode {
                playerCollidedWithDebris(player: player, debris: debris)
            }
        }
    }

}



// Adding '-' to CGPoint
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

// Adding '/' to CGPoint
func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

// Adding length() and normalized() to CGPoint
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
