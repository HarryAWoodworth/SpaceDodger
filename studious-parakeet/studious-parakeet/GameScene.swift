//
//  GameScene.swift
//  studious-parakeet
//
//  Created by Harry Woodworth on 2/18/19.
//  Copyright © 2019 Harry Woodworth. All rights reserved.
//
//
//  References:
//      https://www.raywenderlich.com/71-spritekit-tutorial-for-beginners
//      http://mammothinteractive.com/touches-and-moving-sprites-in-xcode-spritekit-swift-crash-course-free-tutorial/
//      https://stackoverflow.com/questions/25277956/move-a-node-to-finger-using-swift-spritekit
//      https://www.hackingwithswift.com/read/14/4/whack-to-win-skaction-sequences
//      https://www.raywenderlich.com/144-spritekit-animations-and-texture-atlases-in-swift
//      https://www.appcoda.com/spritekit-introduction/
//      https://developer.apple.com/documentation/swift/string
//

import SpriteKit

// Constraints for physics categories
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let monster   : UInt32 = 0b1       // Monster (1)
    static let player    : UInt32 = 0b10      // Player (2)
}

class GameScene: SKScene
{
    private var player = SKSpriteNode()
    private var playerBoostFrames: [SKTexture] = []
    private var debrisWaitDuration = 2.0
    private var score = 0
    private var scoreLabel = SKLabelNode()
    
    var currentAction: SKAction? = nil
    
    // Runs after the scene is presented to the view
    override func didMove(to view: SKView)
    {
        backgroundColor = SKColor.black
        
        // Add player sprite
        buildPlayerSprite()
        
        // Animate player sprite
        animatePlayerBoost()
        
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
        
        // Run addDebris in a loop
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addDebris),
                SKAction.wait(forDuration: debrisWaitDuration)
                ])
        ))

        // Run scoring/debris duration modifier in a loop
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(scoreDebrisMod),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
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
        
        playerBoostFrames = boostFrames
        
        // Set/Add player sprite
        player = SKSpriteNode(texture: playerBoostFrames[0])
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.setScale(1.5)
        addChild(player)
    }
    
    func buildScoreLabel()
    {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 10)
        scoreLabel.setScale(1.0)
        addChild(scoreLabel)
    }
    
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
    
    // Run all the actions added to the sequence and create stars
    func updateGame()
    {
        if(currentAction != nil) {
            player.run(currentAction!)
        }
        //addStar()
    }
    
    // Add touches to the action sequence
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else { return }
        let touchLoc = touch.location(in: self)
        
        let direction = player.position - touchLoc
        
        currentAction = SKAction.move(to: touchLoc, duration: 0.5 * Double(direction.length()/100) )
    }
    
    // Random functions
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    // Create debris objects
    func addDebris()
    {
        let debris = SKSpriteNode(imageNamed: "Debris")
        
        let sizeRandom = random(min: 1.0, max: 5.0 )
        
        debris.setScale(sizeRandom)
        
        let randomX = random(min: 0, max: size.width)
        debris.position = CGPoint(x: randomX, y: size.height + debris.size.height)
        
        addChild(debris)
        
        let randomDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        
        let moveAction = SKAction.move(to: CGPoint(x: randomX, y: -debris.size.height), duration: TimeInterval(randomDuration))
        
        let deleteAction = SKAction.removeFromParent()
        
        debris.run(SKAction.sequence([moveAction,deleteAction]))

    }
    
    // Create a star off screen at the top
    func addStar()
    {
        let star = SKSpriteNode(imageNamed: "Star")
        
        star.setScale(random(min: 0.5, max: 4.0 ))
        
        let randomX = random(min: 0, max: size.width)
        star.position = CGPoint(x: randomX, y: size.height + star.size.height)
        
        addChild(star)
        
        let randomDuration = random(min: CGFloat(2.0), max: CGFloat(6.0))
        
        let moveAction = SKAction.move(to: CGPoint(x: randomX, y: -star.size.height), duration: TimeInterval(randomDuration))
        
        let deleteAction = SKAction.removeFromParent()
        
        star.run(SKAction.sequence([moveAction,deleteAction]))
    }
    
    // Increase the score and decrease the debris wait duration
    func scoreDebrisMod()
    {
        score += 1
        scoreLabel.text = "Score: \(score)\nDebrisWaitDuration: \(debrisWaitDuration)"
        
        if(debrisWaitDuration > 0) {
            debrisWaitDuration -= 0.1
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
