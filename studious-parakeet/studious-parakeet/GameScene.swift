//
//  GameScene.swift
//  studious-parakeet
//
//  Created by Harry Woodworth on 2/18/19.
//  Copyright © 2019 Harry Woodworth. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    // Save where the player last touched
    var lastTouch: CGPoint? = nil
    
    let player = SKSpriteNode(imageNamed: "Player" )
    
    // Runs after the scene is presented to the view
    override func didMove(to view: SKView)
    {
        backgroundColor = SKColor.darkGray
        
        // Add player sprite
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.setScale(0.25)
        addChild(player)
        
        run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(updateGame),
                    SKAction.wait(forDuration: 1.0)
                ])
            ))
    
    }
    
    
    func updateGame()
    {
        if(lastTouch != nil)
        {
            player.position.x = (lastTouch?.x)!
            player.position.y = (lastTouch?.y)!
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            lastTouch = touch.location(in: self)
        }
    }
    
    
    
}
