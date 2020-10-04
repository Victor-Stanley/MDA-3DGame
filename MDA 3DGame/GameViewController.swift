//
//  GameViewController.swift
//  MDA 3DGame
//
//  Created by Viktor Pavlov on 02.10.2020.
//  Copyright © 2020 Viktor Stanley. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    var duration:TimeInterval = 5
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: " + String(self.score)
        }
    }
    
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    
    // the ship
    var ship:SCNNode!
    
    var tapGesture:UITapGestureRecognizer!
    
    var getShip: SCNNode? {
        scene.rootNode.childNode(withName: "ship", recursively: true)
    }
    
    func spanShip() {
        ship = SCNScene(named: "art.scnassets/ship.scn")!.rootNode.clone()
        
        //Add ship at scene
        scene.rootNode.addChildNode(ship)
        
        //Postion the ship
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -105
        let position = SCNVector3 (x,y,z)
        ship.position = position
        
        //look at position
        let lookAtPosition = SCNVector3 (2 * x, 2 * y, 2 * z)
        ship.look(at: lookAtPosition)
        
        //animate
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            self.removeShip()
            DispatchQueue.main.async {
                self.scnView.removeGestureRecognizer(self.tapGesture)
                self.scoreLabel.text = "Game over: " + String(self.score)
            }
            
        }
    }
    
    func removeShip () {
        getShip?.removeFromParentNode()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.numberOfLines = 2
        
        removeShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
            
        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
                
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        
            
        //load ship
        spanShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
             
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.25
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//
//                material.emission.contents = UIColor.black
//
//                SCNTransaction.commit()
                self.ship.removeAllActions()
                self.removeShip()
                
                self.score+=1
                
                self.duration *= 0.9
                                
                self.spanShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
