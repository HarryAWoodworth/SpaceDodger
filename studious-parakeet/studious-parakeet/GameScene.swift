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
    
    let player = SKSpriteNode(imageNamed: "Player" )
    
    // Runs after the scene is presented to the view
    override func didMove(to view: SKView)
    {
        backgroundColor = SKColor.darkGray
        
        // Add player sprite
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        player.setScale(0.5)
        addChild(player)
    }
}
