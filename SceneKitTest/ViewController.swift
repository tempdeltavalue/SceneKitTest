//
//  ViewController.swift
//  SceneKitTest
//


import UIKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    var timer = Timer()

    private var isComputationInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // frog : 12270_Frog_v1_L3.obj
        // cat : 12222_Cat_v1_l3
        let scene = SCNScene(named: "12222_Cat_v1_l3.obj")

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        scene?.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene?.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)

        sceneView.allowsCameraControl = true

        // sceneView.showsStatistics = true

        sceneView.backgroundColor = UIColor.systemGreen

        sceneView.cameraControlConfiguration.allowsTranslation = false

        sceneView.scene = scene
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            // your code here

            self?.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] _ in
                self?.updateCounting()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate();
    }
}

extension ViewController {
    func updateCounting(){
        
        if isComputationInProgress { return }
        print("start computation")

//        resultImageView.image = OpenCVWrapper.edgeDetection(self.sceneView.snapshot());
        
        isComputationInProgress = true

        // Perform a computation in a background thread
        DispatchQueue.global(qos: .background).async {
            let image = OpenCVWrapper.runSAM(self.sceneView.snapshot())
            
            DispatchQueue.main.async { [weak self] in
                self?.resultImageView.image = image
                self?.isComputationInProgress = false;
                print("computation finished")

            }
            
        }
        
    }
}

