//
//  GameViewController.swift
//  studious-parakeet
//
//  Created by Harry Woodworth on 2/18/19.
//  Copyright © 2019 Harry Woodworth. All rights reserved.
//

import SpriteKit

// Standard View Controller
class GameViewController: UIViewController
{
    // Display the game scene right after the controller's view is loaded
    override func viewDidLoad()
    {
        // Create the scene and put it into a view
        let scene = GameScene(size: view.frame.size)
        let skView = view as! SKView
        
        // Settings
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
    }
}
