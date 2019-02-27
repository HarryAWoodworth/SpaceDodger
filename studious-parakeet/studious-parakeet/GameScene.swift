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
//
//

import SpriteKit

class GameScene: SKScene
{
    private var player = SKSpriteNode()
    private var playerBoostFrames: [SKTexture] = []
    
    var currentAction: SKAction? = nil
    
    // Runs after the scene is presented to the view
    override func didMove(to view: SKView)
    {
        backgroundColor = SKColor.darkGray
        
        // Add player sprite
        buildPlayerSprite()
        
        // Animate player sprite
        animatePlayerBoost()
        
        // Run update game 10 times a second
        run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(updateGame),
                    SKAction.wait(forDuration: 0.1)
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
    
    // Run all the actions added to the sequence
    func updateGame()
    {
        if(currentAction != nil) {
            player.run(currentAction!)
        }
    }
    
    // Add touches to the action sequence
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else { return }
        let touchLoc = touch.location(in: self)
        
        let direction = player.position - touchLoc
        
        currentAction = SKAction.move(to: touchLoc, duration: 0.5 * Double(direction.length()/100) )
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
