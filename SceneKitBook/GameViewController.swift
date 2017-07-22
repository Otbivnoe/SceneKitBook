//
//  GameViewController.swift
//  SceneKitBook
//
//  Created by Nikita Ermolenko on 22/07/2017.
//  Copyright © 2017 Nikita Ermolenko. All rights reserved.
//

import UIKit
import SceneKit
class GameViewController: UIViewController {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupScene()
        setupView()
    }

    func setupView() {
        scnView = view as! SCNView
        scnView.scene = scnScene
    }

    func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
        scnScene.rootNode.addChildNode(cameraNode)
    }

    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
    }
}
