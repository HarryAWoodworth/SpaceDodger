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
    let label = SKLabelNode(text: "Hello SpriteKit!")
    
    // Runs after the scene is presented to the view
    override func didMove(to view: SKView)
    {
        // Set the label's position in the view (center)
        label.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        // Add the label as a child node to the scene
        addChild(label)
    }
}
