//
//  ViewController.swift
//  ARTexts
//
//  Created by James Folk on 9/25/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    var locationManager: CLLocationManager!
    
    var currentCLLocation: CLLocation?
    
    let coreMotionManager = CMMotionManager()
    
    var currentAttitude:CMAttitude?
    
    var startAttitude:CMAttitude?
    var startYaw:Double = 0.0
    var startPitch:Double = 0.0
    var startRoll:Double = 0.0
    
    var currentCameraLocation: matrix_float4x4?
    
    private var currentField : UITextField?
    
    private var currentLabel : SKLabelNode? = nil
    public var createNew : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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
    
    func endEditing(_ label: SKLabelNode)
    {
        if createNew
        {
            if label.text != ""
            {
                //MARK: Create the label from the scene
                print("ADDED a new artext to the scene")
            }
        }
        else
        {
            if label.text == ""
            {
                deleteLabel(label)
            }
            else
            {
                //MARK: Update the label from the scene
                print("UPDATED the artext")
            }
        }
    }
    
    func deleteLabel(_ label: SKLabelNode)
    {
        guard let cancelButton = label.childNode(withName: "cancelButton") else {return}
        cancelButton.isHidden = true
        label.isHidden = true
        
        cancelButton.removeFromParent()
        label.removeFromParent()
        
        //MARK: Delete the label from the scene
        print("njli_fopen the artext")
    }
    
    func createLabel(_ text: String, labelNodeFor textAnchor: ARAnchorText)
    {
        let label = SKLabelNode(fontNamed: "Courier-Bold")
        label.text = text
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.name = "label"
        label.userData = ["textAnchor" : textAnchor]
        
        let cancelButton = SKSpriteNode(imageNamed: "Cancel")
        cancelButton.position = CGPoint(x: 0, y: label.frame.size.height + (label.frame.size.height * 0.5))
        cancelButton.name = "cancelButton"
        label.addChild(cancelButton)
        
        createNew = true
        
        currentLabel = label
    }
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        
        let previousLabel = currentLabel
        
        
        let textAnchor:ARAnchorText = anchor as! ARAnchorText
        
        self.createLabel(textAnchor.text, labelNodeFor: textAnchor)
        
        self.handleKeyboard(textAnchor.text)
        
        if nil != previousLabel
        {
            if previousLabel?.text == ""
            {
                deleteLabel(previousLabel!)
            }
            else
            {
                guard let cancelButton = previousLabel?.childNode(withName: "cancelButton") else {return currentLabel}
                cancelButton.isHidden = true
                self.endEditing(previousLabel!)
            }
        }
        
        return currentLabel;
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
    
    func startRemoteARSession()
    {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        
        guard let latitude:Double = self.currentCLLocation?.coordinate.latitude else {
            print("Error: cannot create URL")
            return
        }
        
        guard let longitude:Double = self.currentCLLocation?.coordinate.longitude else {
            print("Error: cannot create URL")
            return
        }
        
        guard let altitude:Double = self.currentCLLocation?.altitude else {
            print("Error: cannot create URL")
            return
        }
        
        guard let horizontalAccuracy:Double = self.currentCLLocation?.horizontalAccuracy else {
            print("Error: cannot create URL")
            return
        }
        
        guard let verticalAccuracy:Double = self.currentCLLocation?.verticalAccuracy else {
            print("Error: cannot create URL")
            return
        }
        
        guard let course:Double = self.currentCLLocation?.course else {
            print("Error: cannot create URL")
            return
        }
        
        guard let speed:Double = self.currentCLLocation?.speed else {
            print("Error: cannot create URL")
            return
        }
    }
    
    func handleKeyboard(_ text:String)
    {
        if(self.currentField != nil)
        {
            self.currentField?.removeFromSuperview()
            self.currentField?.resignFirstResponder()
            self.currentField = nil
        }
        
        if(self.currentField == nil)
        {
            self.currentField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            self.currentField?.delegate = self
            self.currentField?.isHidden = true
            self.view?.addSubview(self.currentField!)
        }
        self.currentField?.text = text
        self.currentField?.becomeFirstResponder()
    }
}

extension ViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var startCMSession:Bool = false
        if(currentCLLocation == nil)
        {
            startCMSession = true
        }
        
        currentCLLocation = locations[0]
        if(currentCLLocation == nil)
        {
            return
        }
        
        if(startCMSession)
        {
            if coreMotionManager.isDeviceMotionAvailable {
                
                coreMotionManager.startDeviceMotionUpdates(to: .main) {
                    [weak self] (data: CMDeviceMotion?, error: Error?) in
                    
                    guard let data = data else { return }
                    
                    self?.currentAttitude = data.attitude
                    
                    if (self?.startAttitude == nil)
                    {
                        self?.startAttitude = data.attitude
                        
                        self?.startRoll = (self?.startAttitude?.roll)!
                        self?.startYaw = (self?.startAttitude?.yaw)!
                        self?.startPitch = (self?.startAttitude?.pitch)!
                        
                        self?.startRemoteARSession()
                    }
                }
            }
        }
    }
}

extension ViewController:ARSessionDelegate
{
    func session(_ session: ARSession,
                 didUpdate frame: ARFrame)
    {
        currentCameraLocation = frame.camera.transform
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
}

extension ViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        guard let label = currentLabel else { return true }
        label.text = newString
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        DispatchQueue.main.async {
            guard let cancelButton = self.currentLabel?.childNode(withName: "cancelButton") else {return}
            cancelButton.isHidden = true
            
            self.view.endEditing(true)
            self.endEditing(self.currentLabel!)
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        print("end editing")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        DispatchQueue.main.async {
            textField.selectAll(nil)
            
        }
    }
}
