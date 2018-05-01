//
//  ViewController.swift
//  ARPilot
//
//  Created by 吳德彥 on 26/04/2018.
//  Copyright © 2018 吳德彥. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var ship: SCNNode?
    var drone: SCNNode?
    var photoNodes: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin];
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        ship = scene.rootNode.childNodes.first
        
        // load drone
        let droneScene = SCNScene(named: "art.scnassets/Drone.dae")!
        drone = droneScene.rootNode

        sceneView.scene = scene
        
    }
    
    @IBAction func shoot(_ sender: Any) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000, height: sceneView.bounds.height / 6000)
        
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)

        planeNode.transform = SCNMatrix4Rotate(planeNode.transform, Float.pi / 2, 0, 0, 1)
        planeNode.transform = SCNMatrix4Translate(planeNode.transform, 0, 0, -0.1)

        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, planeNode.simdTransform)
        
        photoNodes.append(planeNode)
    }
    
    @IBAction func preview(_ sender: Any) {
        guard drone != nil && photoNodes.count > 0 else {return}
        
        sceneView.scene.rootNode.addChildNode(drone!)
        drone!.position = photoNodes.first!.position
        drone!.rotation = photoNodes.first!.rotation

        var actions: [SCNAction] = []
        for photoNode in photoNodes[1 ..< photoNodes.count] {
            
            let moveAction = SCNAction.move(to: photoNode.position, duration: 1)
            let rotateAction = SCNAction.rotateTo(x: CGFloat(photoNode.rotation.x), y: CGFloat(photoNode.rotation.y), z: CGFloat(photoNode.rotation.z), duration: 1)
            actions.append(SCNAction.group([moveAction, rotateAction]))
        }
        
        photoNodes.forEach { (node) in
            node.isHidden = true
        }
        drone?.runAction(SCNAction.sequence(actions), completionHandler: {
            self.drone?.removeFromParentNode()
            self.photoNodes.forEach { (node) in
                node.isHidden = false
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    // Note that ARKit controls the node's visibility and its transform property, so you may find it useful to add child nodes or adjust the node's pivot property to maintain any changes to position or orientation that you make.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let planeNode = SCNNode()
    
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        plane.firstMaterial?.lightingModel = .constant
        planeNode.geometry = plane
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0);
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let plane = node.childNodes.first, let planeGeometry = plane.geometry as? SCNPlane {
            
            // first, we update the extent of the plane, because it might have changed
            planeGeometry.width = CGFloat(arPlaneAnchor.extent.x)
            planeGeometry.height = CGFloat(arPlaneAnchor.extent.z)
            
            // now we should update the position (remember the transform applied)
            plane.position = SCNVector3(arPlaneAnchor.center.x, 0, arPlaneAnchor.center.z)
        }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
