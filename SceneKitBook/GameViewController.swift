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

        spawnShape()
    }

    func setupView() {
        scnView = view as! SCNView
        scnView.scene = scnScene

        scnView.showsStatistics = true /// enables a real-time statistics panel at the bottom of your scene.
        scnView.allowsCameraControl = true /// lets you manually control the active camera through simple gestures.
        scnView.autoenablesDefaultLighting = true /// creates a generic omnidirectional light in your scene so you don’t have to worry about adding your own light sources.
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

    func spawnShape() {
        let geometry: SCNGeometry

        switch ShapeType.random() {
        case .box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }

        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
    }
}
