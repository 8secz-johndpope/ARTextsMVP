//
//  Scene.swift
//  ARTexts
//
//  Created by James Folk on 9/25/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    private var currentAnchor:ARAnchorText?
    private var startTouch:UITouch?
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the first touch
        guard let touch = touches.first else {
            return
        }
        // Get the location in the AR scene
        let location = touch.location(in: self)
        
        // Get the nodes at that location
        let hit = nodes(at: location)
        
        // Get the first node (if any)
        if let node = hit.first
        {
            guard let name = node.name else { return }
            
            if name == "cancelButton"
            {
                guard let label = node.parent as? SKLabelNode else { return }
                guard let viewController = self.view!.window!.rootViewController as? ViewController else { return }
                guard let field = viewController.currentField else { return }
                
                label.text = ""
                field.text = ""
            }
            else if name == "label"
            {
                guard let cancelButton = node.childNode(withName: "cancelButton") else {return}
                cancelButton.isHidden = false
                
                if let dictParams: NSMutableDictionary = node.userData
                {
                    if let textAnchor:ARAnchorText = dictParams.object(forKey: "textAnchor") as? ARAnchorText
                    {
                        currentAnchor = textAnchor
                        startTouch = touch
                        
                        print("The text is: `%s`", textAnchor.text)
                        let viewController = self.view!.window!.rootViewController as! ViewController
                        viewController.createNew = false
                        viewController.handleKeyboard(textAnchor.text)
                        viewController.currentLabel = (node as! SKLabelNode)
                        viewController.fontPicker.isHidden = false
                    }
                }
            }
            else
            {
                
            }
        }
        else
        {
            guard let sceneView = self.view as? ARSKView else {
                return
            }
            
            // Create anchor using the camera's current position
            if let currentFrame = sceneView.session.currentFrame {
                
                // Create a transform with a translation of 0.2 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                let transform = simd_mul(currentFrame.camera.transform, translation)
                
                // Add a new anchor to the session
                let anchor = ARAnchorText(transform: transform)
                sceneView.session.add(anchor: anchor)
                
                currentAnchor = anchor
                startTouch = touch
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        currentAnchor = nil
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touchBegin = startTouch else { return }
        guard let touch = touches.first else { return }
        guard let anchor = currentAnchor else { return }
        guard let viewController = self.view!.window!.rootViewController as? ViewController else { return }

        
    }
    
    func loadText(_ transform: matrix_float4x4, _ id: String)
    {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Add a new anchor to the session
        let anchor = ARAnchorText(transform: transform)
        sceneView.session.add(anchor: anchor)
        
        anchor.userData = ["textID" : id]
        
    }
}
