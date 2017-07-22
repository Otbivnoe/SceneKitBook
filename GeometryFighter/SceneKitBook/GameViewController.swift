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

    var spawnTime: TimeInterval = 0

    var splashNodes: [String: SCNNode] = [:]
    var game = GameHelper.sharedInstance

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
        setupHUD()
        setupSplash()
        setupSounds()
    }

    // MARK: - Setup

    func setupView() {
        scnView = view as! SCNView
        scnView.scene = scnScene
        scnView.delegate = self

        // By default, SceneKit enters into a “paused” state if there are no animations to play out.
        scnView.isPlaying = true

        scnView.showsStatistics = true /// enables a real-time statistics panel at the bottom of your scene.
        scnView.allowsCameraControl = false /// lets you manually control the active camera through simple gestures.
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
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
    }

    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }

    func setupSplash() {
        splashNodes["TapToPlay"] = createSplash(name: "TAPTOPLAY", imageFileName: "GeometryFighter.scnassets/Textures/TapToPlay_Diffuse.png")
        splashNodes["GameOver"] = createSplash(name: "GAMEOVER", imageFileName: "GeometryFighter.scnassets/Textures/GameOver_Diffuse.png")
        showSplash(splashName: "TapToPlay")
    }

    func setupSounds() {
        game.loadSound("ExplodeGood", fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeGood.wav")
        game.loadSound("SpawnGood", fileNamed: "GeometryFighter.scnassets/Sounds/SpawnGood.wav")
        game.loadSound("ExplodeBad",  fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeBad.wav")
        game.loadSound("SpawnBad", fileNamed: "GeometryFighter.scnassets/Sounds/SpawnBad.wav")
        game.loadSound("GameOver", fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == .GameOver {
            return
        }

        if game.state == .TapToPlay {
            game.reset()
            game.state = .Playing
            showSplash(splashName: "")
            return
        }

        let touch = touches.first
        let location = touch!.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)

        if let result = hitResults.first {
            if result.node.name == "HUD" || result.node.name == "GAMEOVER" || result.node.name == "TAPTOPLAY" {
                return
            } else if result.node.name == "GOOD" {
                handleGoodCollision()
            } else if result.node.name == "BAD" {
                handleBadCollision()
            }

            createExplosion(geometry: result.node.geometry!, position: result.node.presentation.position, rotation: result.node.presentation.rotation)
            result.node.removeFromParentNode()
        }
    }

    func handleGoodCollision() {
        game.score += 1
        game.playSound(scnScene.rootNode, name: "ExplodeGood")
    }

    func handleBadCollision() {
        game.lives -= 1
        game.playSound(scnScene.rootNode, name: "ExplodeBad")
        game.shakeNode(cameraNode)

        if game.lives <= 0 {
            game.saveState()
            showSplash(splashName: "GameOver")
            game.playSound(scnScene.rootNode, name: "GameOver")
            game.state = .GameOver
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { node in
                self.showSplash(splashName: "TapToPlay")
                self.game.state = .TapToPlay
            })
        }
    }

    // MARK: - Helpers

    func spawnShape() {
        let geometry: SCNGeometry

        switch ShapeType.random() {
        case .box:      geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .sphere:   geometry = SCNSphere(radius: 0.5)
        case .pyramid:  geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:    geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .capsule:  geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .cylinder: geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .cone:     geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .tube:     geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }

        let color = UIColor.random()
        geometry.materials.first?.diffuse.contents = color /// color of the shape

        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)

        let trailEmitter = createTrail(color: color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)

        if color == UIColor.black {
            geometryNode.name = "BAD"
            game.playSound(scnScene.rootNode, name: "SpawnBad")
        } else {
            geometryNode.name = "GOOD"
            game.playSound(scnScene.rootNode, name: "SpawnGood")
        }

        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)

        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)

        // geometryNode.physicsBody?.applyTorque(<#T##torque: SCNVector4##SCNVector4#>, asImpulse: <#T##Bool#>)
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)

        scnScene.rootNode.addChildNode(geometryNode)
    }

    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            // All nodes under animation have a “copied” version called the `presentationNode`.
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }

    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }

    func createExplosion(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface

        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)

        scnScene.addParticleSystem(explosion, transform: transformMatrix)
    }

    // MARK: - Splash

    func createSplash(name: String, imageFileName: String) -> SCNNode {
        let plane = SCNPlane(width: 5, height: 5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: 5, z: 0)
        splashNode.name = name
        splashNode.geometry?.materials.first?.diffuse.contents = imageFileName
        scnScene.rootNode.addChildNode(splashNode)
        return splashNode
    }

    func showSplash(splashName: String) {
        for (name, node) in splashNodes {
            node.isHidden = name != splashName
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if game.state == .Playing {
            if time > spawnTime {
                spawnShape()
                spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
            }
            cleanScene()
        }
        game.updateHUD()
    }
}
